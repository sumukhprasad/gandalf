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
	get "/groups" do
		find_current_user!

		@groups = @user.groups
		
		erb :"groups/index"
	end
	
	get "/groups/:slug" do
		find_current_user!

		@group = @user.groups_dataset.where(slug: params[:slug]).first

		halt 404 unless @group

		erb :"groups/view_group"
	end
	
	get "/groups/:slug/info" do
		find_current_user!

		@group = @user.groups_dataset.where(slug: params[:slug]).first
		

		@memberships = Membership
			.where(group_id: @group.id)
			.eager(:user)
			.all

		halt 404 unless @group

		erb :"groups/view_group_info"
	end
end

