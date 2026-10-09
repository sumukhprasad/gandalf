require "json"
require_relative "config/database"
require_relative "models/user"
require_relative "models/group"
require_relative "models/membership"
require_relative "models/claim"
require_relative "models/assignment"
require_relative "models/verification"
require_relative "models/verification_issue"
require_relative "models/verification_source"

require_relative "lib/email_delivery"
require_relative "lib/email_renderer"


MAX_ATTEMPTS = 8

def process_one_email
	job = DB.transaction do
		now = Time.now

		candidate = DB[:email_jobs]
			.where(status: "pending")
			.where { available_at <= now }
			.order(:id)
			.first

		next nil unless candidate

		DB[:email_jobs]
			.where(id: candidate[:id], status: "pending")
			.update(
				status: "sending",
				locked_at: now,
				attempts: candidate[:attempts] + 1
			)

		DB[:email_jobs].where(id: candidate[:id]).first
	end

	return false unless job

	begin
		email = EmailRenderer.render(job)
		EmailDelivery.send_text(
			to: job[:recipient],
			subject: email.fetch(:subject),
			body: email.fetch(:body)
		)

		DB[:email_jobs].where(id: job[:id]).update(
			status: "sent",
			sent_at: Time.now,
			locked_at: nil,
			last_error: nil
		)
	rescue StandardError => e
		attempts = job[:attempts]
		exhausted = attempts >= MAX_ATTEMPTS

		delay = [2**attempts, 3600].min

		DB[:email_jobs].where(id: job[:id]).update(
			status: exhausted ? "failed" : "pending",
			available_at: Time.now + delay,
			locked_at: nil,
			last_error: e.class.name
		)

		warn "email job #{job[:id]} failed (#{e.class})"
		warn e.message
	end

	true
end

loop do
	worked = process_one_email
	sleep(2) unless worked
end