helpers do
	def require_admin!
		redirect "/" unless @current_user&.role == "admin"
	end
end

configure_routes do
	get "/admin" do
		require_admin!

		erb :"admin/index"
	end
end
