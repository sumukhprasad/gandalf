helpers do
	def require_login!
		halt 401 unless @current_user
	end

	def find_current_user!
		require_login!

		@user = @current_user
	end
	
	def can_edit_claim?(user, group, claim)
		return true if claim.user_id == user.id
		return is_moderator?(user, group)
	end
	
	def is_moderator?(user, group)
		return true if user.role == "admin"

		membership = Membership
			.where(
				user_id: user.id,
				group_id: group.id
			)
			.first

		membership && membership.role == "moderator"
	end
end

configure_routes do
	get "/assignments" do
		find_current_user!
		
		@assignments = Assignment.where(verifier_id: @user.id).sort_by { |c| c.assigned_at }.reverse!
		
		erb :"assignments/index"
	end
end