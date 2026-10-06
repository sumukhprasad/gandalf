Sequel.migration do
	change do
		create_table(:claims) do
			primary_key :id

			foreign_key :group_id, null: false
			foreign_key :user_id, null: false
			
			String :statement, null: false
			String :context, null: false
			String :status, null: false, default: "pending" # pending, assigned, completed, cancelled
			String :initial_reaction, null: false
			String :claimant, null: false

			DateTime :created_at, null: false
			DateTime :updated_at, null: false
		end
	end
end