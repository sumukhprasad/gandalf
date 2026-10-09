require "erb"
require "json"

module EmailRenderer
	TEMPLATE_DIR = File.expand_path("../views/emails", __dir__)

	def self.render(job)
		payload = JSON.parse(job[:payload])

		case job[:kind]
		when "new_user"
			@username = payload.fetch("username")
			template = File.read(
				File.join(TEMPLATE_DIR, "new_user.txt.erb")
			)

			body = ERB.new(template).result(binding)

			{
				subject: "[gandalf] Welcome to Gandalf!",
				body: body
			}
	     when "assignment_created"
	     	assignment = Assignment[payload.fetch("assignment_id")]
	     	raise "assignment not found" unless assignment
            	
	     	claim = Claim[assignment.claim_id]
	     	verifier = User[assignment.verifier_id]
	     	group = Group[claim.group_id]
			
	     	template = File.read(
	     		File.join(TEMPLATE_DIR, "assignment_created.txt.erb")
	     	)
            	
	     	body = ERB.new(template).result(binding)
            	
	     	{
	     		subject: "[gandalf] New assignment",
	     		body: body
	     	}
	     when "verification_submitted"
	     	assignment = Assignment[payload.fetch("assignment_id")]
	     	raise "assignment not found" unless assignment
            	
	     	claim = Claim[assignment.claim_id]
	     	verifier = User[assignment.verifier_id]
	     	creator = User[claim.user_id]
	     	group = Group[claim.group_id]
			
	     	template = File.read(
	     		File.join(TEMPLATE_DIR, "verification_submitted.txt.erb")
	     	)
            	
	     	body = ERB.new(template).result(binding)
            	
	     	{
	     		subject: "[gandalf] Verification submitted",
	     		body: body
	     	}
		else
			raise "unknown email kind: #{job[:kind]}"
		end
	end
end