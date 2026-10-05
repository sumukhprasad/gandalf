require "bcrypt"


configure_routes do
	get "/users/create" do
		erb :user_create
	end
	
	post "/users/create" do
		User.create(
			username: params[:username],
			email: params[:email],
			token_hash: "",
			role: params[:role] || "member",
			created_at: Time.now
		)
		
		erb :home
	end
	
	
	get "/users/login" do
		erb :"users/login"
	end
	
	post "/users/login" do
		user = User.first(username: params[:username])

		unless user && user.active
			halt 401
		end

		if user.token_hash == ""
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
	
	get "/users/logout" do
		if @current_user
			@current_user = nil
			session.delete(:user_id)
		end
		
		redirect "/"
	end
end


error 401 do
    erb :"users/invalid"
end

