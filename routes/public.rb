configure_routes do
	get "/" do
		if @current_user
			@claims = @current_user.claims.sort_by { |c| c.updated_at }.reverse!.select{ |c| c.status != "completed" }
			@assignments = Assignment.where(verifier_id: @current_user.id, status: "active").sort_by { |c| c.assigned_at }.reverse!
			erb :home
		else
			erb :"users/login"
		end
	end
end