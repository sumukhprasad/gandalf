Sequel.migration do
	change do
		create_table(:memberships) do
			primary_key :id

			foreign_key :group_id, null: false
			foreign_key :user_id, null: false
			
			String :role, null: false, default: "member"
			TrueClass :is_verifier, null: false, default: false

			DateTime :created_at, null: false
			
			unique [:group_id, :user_id]
		end
	end
end