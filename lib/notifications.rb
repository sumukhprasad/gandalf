require "json"
require "time"


module Notifications
	def self.enqueue(recipient:, kind:, payload:)
		DB[:email_jobs].insert(
			recipient: recipient,
			kind: kind,
			payload: JSON.generate(payload),
			status: "pending",
			attempts: 0,
			available_at: Time.now,
			created_at: Time.now
		)
	end
end