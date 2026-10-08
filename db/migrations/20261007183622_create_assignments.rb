Sequel.migration do
	change do
		create_table(:assignments) do
			primary_key :id

			foreign_key :claim_id, :claims, null: false
			foreign_key :verifier_id, :users, null: false

			String :status, null: false, default: "active"

			DateTime :assigned_at, null: false
			DateTime :completed_at
			DateTime :rescinded_at

			foreign_key :created_by, :users

			String :reason
		end

		add_index :assignments, :claim_id
		add_index :assignments, :verifier_id
		add_index :assignments, [:claim_id, :status]
	end
end