require "mail"

Mail.defaults do
	delivery_method :smtp, {
		address: ENV.fetch("SMTP_ADDRESS"),
		port: ENV.fetch("SMTP_PORT", "587").to_i,
		user_name: ENV.fetch("SMTP_USERNAME"),
		password: ENV.fetch("SMTP_PASSWORD"),
		authentication: :plain,
		enable_starttls_auto: true
	}
end

module EmailDelivery
	def self.send_text(to:, subject:, body:)
		message = Mail.new do
			from    ENV.fetch("SMTP_USERNAME")
			to      to
			subject subject
			text_part do
			 	body body
			end
		end
		
		message.deliver!
	end
end