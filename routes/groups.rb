helpers do
	def require_login!
		halt 401 unless @current_user
	end

	def find_current_user!
		require_login!

		@user = @current_user
	end
	
	def can_edit_claim?(user, group, claim)
		return true if claim.user_id == user.id
		return is_moderator?(user, group)
	end
	
	def is_moderator?(user, group)
		return true if user.role == "admin"

		membership = Membership
			.where(
				user_id: user.id,
				group_id: group.id
			)
			.first

		membership && membership.role == "moderator"
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

		@claims = @group.claims_dataset
			.eager(:user)
			.order(Sequel.desc(:created_at))
			.all


		erb :"groups/view_group"
	end
	
	get "/groups/:slug/info" do
		find_current_user!
		@group = @user.groups_dataset.where(slug: params[:slug]).first
		@is_mod = is_moderator?(@user, @group)
		
		halt 404 unless @group

		@memberships = Membership
			.where(group_id: @group.id)
			.eager(:user)
			.all

		erb :"groups/view_group_info"
	end

	get "/groups/:slug/claims/new" do
		find_current_user!
		@group = @user.groups_dataset.where(slug: params[:slug]).first
		halt 404 unless @group

		erb :"claims/new"
	end

	post "/groups/:slug/claims" do
		find_current_user!
		@group = @user.groups_dataset.where(slug: params[:slug]).first
		halt 404 unless @group

		@claim = Claim.new(
			group_id: @group.id,
			user_id: @user.id,
			statement: params[:statement],
			context: params[:context],
			status: "pending",
			claimant: params[:claimant],
			initial_reaction: params[:initial_reaction],
			created_at: Time.now,
			updated_at: Time.now
		)

		if @claim.valid?
			@claim.save

			redirect "/groups/#{@group.slug}/claims/#{@claim.id}"
		end

		erb :"claims/new"
	end

	get "/groups/:slug/claims/:id" do
		find_current_user!
		@group = @user.groups_dataset.where(slug: params[:slug]).first
		halt 404 unless @group

		@claim = @group.claims_dataset
			.eager(:user)
			.where(id: params[:id])
			.first

		halt 404 unless @claim
		@can_edit = can_edit_claim?(@user, @group, @claim)

		erb :"claims/view"
	end

	get "/groups/:slug/claims/:id/edit" do
		find_current_user!
		@group = @user.groups_dataset.where(slug: params[:slug]).first
		halt 404 unless @group

		@claim = @group.claims_dataset
			.where(id: params[:id])
			.first

		halt 404 unless @claim
		halt 403, "Not authorised." unless can_edit_claim?(@user, @group, @claim)

		erb :"claims/edit"
	end

	post "/groups/:slug/claims/:id/edit" do
		find_current_user!
		@group = @user.groups_dataset.where(slug: params[:slug]).first
		halt 404 unless @group

		@claim = @group.claims_dataset
			.where(id: params[:id])
			.first

		halt 404 unless @claim
		halt 403, "Not authorised." unless can_edit_claim?(@user, @group, @claim)

		@claim.update(
			statement: params[:statement],
			context: params[:context],
			status: params[:status],
			claimant: params[:claimant],
			updated_at: Time.now
		)

		if @claim.valid?
			@claim.save

			redirect "/groups/#{@group.slug}/claims/#{@claim.id}"
		end

		erb :"claims/edit"
	end
	
	
	
	
	
	
	
	
	get "/groups/:slug/members/add" do		
		find_current_user!
		@group = @user.groups_dataset.where(slug: params[:slug]).first
		halt 404 unless @group
		halt 403 unless is_moderator?(@user, @group)

		erb :"groups/add_member"
	end
	

	post "/groups/:slug/members/add" do
		find_current_user!
		@group = @user.groups_dataset.where(slug: params[:slug]).first
		halt 404 unless @group
		halt 403 unless is_moderator?(@user, @group)

		username = params[:username].to_s.strip

		halt 404, "No username" unless username

		user = User.where(username: username).first

		halt 404, "User not found" unless user

		membership = Membership.where(
			group_id: @group.id,
			user_id: user.id
		).first

		if membership
			halt 403, "Already a member"
		else
			Membership.create(
				group_id: @group.id,
				user_id: user.id,
				role: params[:role].to_s.strip.empty? ? "member" : params[:role],
				is_verifier: params[:is_verifier] == nil ? false : true,
				created_at: Time.now
			)
		end

		redirect "/groups/#{@group.slug}/info"
	end
	
	
	get "/groups/:slug/members/:username/edit" do
		find_current_user!
		@group = @user.groups_dataset.where(slug: params[:slug]).first
		halt 404 unless @group
		halt 403 unless is_moderator?(@user, @group)

		user = User.where(username: params[:username]).first
		halt 404, "User not found" unless user

		@membership = Membership.where(
			group_id: @group.id,
			user_id: user.id
		).first

		halt 404, "Membership not found" unless @membership

		erb :"groups/edit_member"
	end
	
	post "/groups/:slug/members/:username/edit" do
		find_current_user!
		@group = @user.groups_dataset.where(slug: params[:slug]).first
		halt 404 unless @group
		halt 403 unless is_moderator?(@user, @group)

		user = User.where(username: params[:username]).first
		halt 404, "User not found" unless user

		membership = Membership.where(
			group_id: @group.id,
			user_id: user.id
		).first

		halt 404, "Membership not found" unless membership

		role = params[:role].to_s.strip

		halt 400, "Invalid role" unless %w[member moderator].include?(role)

		membership.update(
			role: role,
			is_verifier: params[:is_verifier]
		)

		redirect "/groups/#{@group.slug}/info"
	end


	post "/groups/:slug/members/:username/delete" do
		find_current_user!
		@group = @user.groups_dataset.where(slug: params[:slug]).first
		halt 404 unless @group
		halt 403 unless is_moderator?(@user, @group)

		user = User.where(username: params[:username]).first

		halt 404, "User not found" unless user

		membership = Membership.where(
			group_id: @group.id,
			user_id: user.id
		).first

		halt 404, "Not a member" unless membership

		membership.delete

		redirect "/groups/#{@group.slug}"
	end
end