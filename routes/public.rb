configure_routes do
	get "/" do
		if @current_user
			erb :home
		else
			erb :"users/login"
		end
	end
end