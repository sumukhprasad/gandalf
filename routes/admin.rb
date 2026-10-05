configure_routes do
	get "/admin" do
		if !(@current_user && @current_user.role=="admin")
			redirect "/"
		end
		
		@users = User.all
		
		erb :"admin/index"
	end
	

	get "/admin/create_user" do
		if !(@current_user && @current_user.role=="admin")
			redirect "/"
		end
		
		erb :"admin/create_user"
	end
	
	post "/admin/create_user" do
		if !(@current_user && @current_user.role=="admin")
			redirect "/"
		end
		
		User.create(
			username: params[:username],
			email: params[:email],
			token_hash: "",
			role: params[:role] || "member",
			created_at: Time.now
		)

		redirect "/admin"
	end
end
