helpers do
	def find_group!
		group = Group.first(slug: params[:slug])

		halt 404, "Group not found" unless group
		group
	end
end

configure_routes do
	get "/admin/groups/:slug/members/add" do
		require_admin!
		@group = find_group!

		erb :"admin/groups/add_member"
	end
	

	post "/admin/groups/:slug/members/add" do
		require_admin!

		@group = find_group!

		username = params[:username].to_s.strip

		halt 404, "No username" unless username

		user = User.where(username: username).first

		halt 404, "User not found" unless user

		membership = Membership.where(
			group_id: @group.id,
			user_id: user.id
		).first

		if membership
			halt 403, "Already a member"
		else
			Membership.create(
				group_id: @group.id,
				user_id: user.id,
				role: params[:role].to_s.strip.empty? ? "member" : params[:role],
				is_verifier: params[:is_verifier] == nil ? false : true,
				created_at: Time.now
			)
		end

		redirect "/admin/groups/#{@group.slug}"
	end
	
	
	get "/admin/groups/:slug/members/:username/edit" do
		require_admin!

		@group = find_group!

		user = User.where(username: params[:username]).first
		halt 404, "User not found" unless user

		@membership = Membership.where(
			group_id: @group.id,
			user_id: user.id
		).first

		halt 404, "Membership not found" unless @membership

		erb :"admin/groups/edit_member"
	end
	
	post "/admin/groups/:slug/members/:username/edit" do
		require_admin!

		@group = find_group!

		user = User.where(username: params[:username]).first
		halt 404, "User not found" unless user

		membership = Membership.where(
			group_id: @group.id,
			user_id: user.id
		).first

		halt 404, "Membership not found" unless membership

		role = params[:role].to_s.strip

		halt 400, "Invalid role" unless %w[member moderator].include?(role)

		membership.update(
			role: role,
			is_verifier: params[:is_verifier] == nil ? false : true
		)

		redirect "/admin/groups/#{@group.slug}"
	end


	post "/admin/groups/:slug/members/:username/delete" do
		require_admin!

		@group = find_group!

		user = User.where(username: params[:username]).first

		halt 404, "User not found" unless user

		membership = Membership.where(
			group_id: @group.id,
			user_id: user.id
		).first

		halt 404, "Not a member" unless membership

		membership.delete

		redirect "/admin/groups/#{@group.slug}"
	end
end
