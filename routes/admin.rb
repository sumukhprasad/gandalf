helpers do
	def require_admin!
		redirect "/" unless @current_user&.role == "admin"
	end

	def find_user!
		user = User.first(username: params[:username])

		halt 404, "User not found" unless user
		user
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
end
