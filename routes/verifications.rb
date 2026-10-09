helpers do
	def require_login!
		halt 401 unless @current_user
	end

	def find_current_user!
		require_login!

		@user = @current_user
	end
	
	def can_verify?(user, assignment)
		return true if assignment.verifier_id == user.id
		
		false
	end
end




configure_routes do
	get "/verify_assignment/:assgn_id" do
		find_current_user!
		
		@assignment = Assignment.where(id: params[:assgn_id]).first
		halt 404, "Assignment not found" unless @assignment
		halt 403, "Not allowed." unless can_verify?(@user, @assignment)
		
		@claim = @assignment.claim
		
		erb :"verifications/create_verification"
	end
	
	
	post "/verify_assignment/:assgn_id" do
		find_current_user!

		assignment = Assignment[params[:assgn_id]]

		halt 404, "Assignment not found" unless assignment
		halt 403, "Not allowed" unless can_verify?(@user, assignment)
		
		errors = []
		errors << "Select a verdict" if params[:verdict].to_s.empty?
		errors << "Select confidence" if params[:confidence].to_s.empty?
		errors << "Reasoning required" if params[:reasoning].strip.empty?
		errors << "Interpretation required" if params[:interpretation].strip.empty?

		unless errors.empty?
			halt errors
		end

		DB.transaction do
			verification = Verification.create(
				assignment_id: assignment.id,

				verdict: params[:verdict],
				confidence: params[:confidence],

				interpreted_claim: params[:interpretation],
				explanation: params[:reasoning],

				assumptions: params[:assumptions],
				limitations: params[:limitations],

				submitted_at: Time.now,
				updated_at: Time.now
			)

			(params[:problems] || []).each do |problem|
				VerificationIssue.create(
					verification_id: verification.id,
					issue: problem,
					details: nil,
					created_at: Time.now
				)
			end

			if params[:sources]
				params[:sources].each do |s|
					source = s[1]
					VerificationSource.create(
						verification_id: verification.id,
               	
						title: source["title"],
						author: source["author"],
						url: source["URL"],
               			source_type: source["type"],
						relation: source["relationship"],
               	
						excerpt: source["excerpt"],
						location: source["loc"],
						relevance: source["relevance"],
               	
						created_at: Time.now
					)
				end
			end
			
			assignment.update(
				status: "completed",
				completed_at: Time.now
			)

			assignment.claim.update(
				status: "completed"
			)
			

		     Notifications.enqueue(
		     	recipient: User[assignment.claim.user_id].email,
		     	kind: "verification_submitted",
		     	payload: {
		     		"assignment_id" => assignment.id,
		     		"verifier_id" => @user.id
		     	}
		     )
		end

		redirect "/groups/#{assignment.claim.group.slug}/claims/#{assignment.claim.id}"
	end
end
