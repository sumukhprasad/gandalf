require "bcrypt"


helpers do
	def require_login!
		halt 401 unless @current_user
	end

	def find_current_user!
		require_login!

		@user = @current_user
	end
end

configure_routes do
	get "/users/:uname" do
		require_login!
		
		@user =  User.first(username: params[:uname])
		
		halt 401, "No such user." unless @user
		
		erb :"users/public_view"
	end
	
	# login
	get "/users/login" do
		erb :"users/login"
	end

	post "/users/login" do
		user = User.first(username: params[:username])

		unless user && user.active
			halt 401
		end

		if user.token_hash.nil? || user.token_hash == ""
			session[:password_setup_user_id] = user.id
			redirect "/users/set-password"
		end

		token = BCrypt::Password.new(user.token_hash)

		unless token == params[:token]
			halt 401
		end

		session[:user_id] = user.id

		redirect "/"
	end

	# password setup
	get "/users/set-password" do
		halt 403 unless session[:password_setup_user_id]

		erb :"users/set_password"
	end

	post "/users/set-password" do
		user_id = session[:password_setup_user_id]
		halt 403 unless user_id

		user = User[user_id]

		password = params[:password]
		password_confirmation = params[:password_confirmation]

		if password.nil? || password.length < 12
			@error = "password must be at least 12 characters"
			return erb :"users/set_password"
		end

		if password != password_confirmation
			@error = "passwords do not match"
			return erb :"users/set_password"
		end

		user.update(
			token_hash: BCrypt::Password.create(password)
		)

		session.delete(:password_setup_user_id)
		session[:user_id] = user.id

		redirect "/"
	end

	# view own profile
	get "/users/profile" do
		find_current_user!

		erb :"users/view"
	end

	# edit own profile
	get "/users/profile/edit" do
		find_current_user!

		erb :"users/edit"
	end

	# update own profile
	post "/users/profile/edit" do
		find_current_user!

		@user.update(
			username: params[:username],
			email: params[:email]
		)

		redirect "/users/profile"
	end

	post "/users/reset" do
		find_current_user!

		@user.update(
			token_hash: ""
		)

		session.delete(:user_id)

		redirect "/"
	end

	# logout
	get "/users/logout" do
		session.delete(:user_id)
		redirect "/"
	end
end


error 401 do
    erb :"users/invalid"
end

