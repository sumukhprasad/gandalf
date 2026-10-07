helpers do
	def find_group!
		group = Group.first(slug: params[:slug])

		halt 404, "Group not found" unless group
		group
	end
end

configure_routes do
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
			slug: params[:slug].downcase.tr(" ","_"),
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
			slug: params[:slug_new].downcase.tr(" ","_"),
		)

		redirect "/admin/groups/#{@group.slug}"
	end
end
