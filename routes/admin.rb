helpers do
	def require_admin!
		redirect "/" unless @current_user&.role == "admin"
	end

	def find_user!
		user = User.first(username: params[:username])

		halt 404, "User not found" unless user
		user
	end

	def find_group!
		group = Group.first(slug: params[:slug])

		halt 404, "Group not found" unless group
		group
	end
end

configure_routes do
	get "/admin" do
		require_admin!

		erb :"admin/index"
	end
	
	
	
	
	# USERS
	get "/admin/users" do
		require_admin!

		@users = User.all
		erb :"admin/users/index"
	end


	get "/admin/users/create_user" do
		require_admin!

		erb :"admin/users/create_user"
	end

	post "/admin/users/create_user" do
		require_admin!

		User.create(
			username: params[:username],
			email: params[:email],
			token_hash: "",
			role: params[:role] || "member",
			active: true,
			created_at: Time.now
		)

		redirect "/admin/users"
	end


	get "/admin/users/:username" do
		require_admin!

		@user = find_user!

		erb :"admin/users/view_user"
	end


	get "/admin/users/:username/edit" do
		require_admin!

		@user = find_user!

		erb :"admin/users/edit_user"
	end


	post "/admin/users/:username/edit" do
		require_admin!

		@user = find_user!

		@user.update(
			username: params[:username],
			email: params[:email],
			role: params[:role]
		)

		redirect "/admin/users/#{@user.username}"
	end


	post "/admin/users/:username/toggle" do
		require_admin!

		@user = find_user!

		@user.update(
			active: !@user.active
		)

		redirect "/admin/users/#{@user.username}"
	end

	post "/admin/users/:username/reset" do
		require_admin!

		@user = find_user!

		@user.update(
			token_hash: ""
		)

		redirect "/admin/users/#{@user.username}"
	end	
	
	
	# GROUPS
	get "/admin/groups" do
		require_admin!
		@groups = Group.all
		erb :"admin/groups/index"
	end


	get "/admin/groups/create_group" do
		require_admin!

		erb :"admin/groups/create_group"
	end

	post "/admin/groups/create_group" do
		require_admin!

		Group.create(
			name: params[:name],
			slug: params[:slug],
			created_at: Time.now
		)

		redirect "/admin/groups"
	end


	get "/admin/groups/:slug" do
		require_admin!

		@group = find_group!
		@memberships = @group.memberships_dataset
			.eager(:user)
			.order(Sequel.asc(:created_at))
			.all

		erb :"admin/groups/view_group"
	end


	get "/admin/groups/:slug/edit" do
		require_admin!

		@group = find_group!

		erb :"admin/groups/edit_group"
	end


	post "/admin/groups/:slug/edit" do
		require_admin!

		@group = find_group!

		@group.update(
			name: params[:name],
			slug: params[:slug_new],
		)

		redirect "/admin/groups/#{@group.slug}"
	end
	
	
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
			halt 403, "Already a member" unless user
		else
			Membership.create(
				group_id: @group.id,
				user_id: user.id,
				role: params[:role].to_s.strip.empty? ? "member" : params[:role],
				created_at: Time.now
			)
		end

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
