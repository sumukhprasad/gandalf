Sequel.migration do
	change do
		create_table(:users) do
			primary_key :id

			String :username, null: false, unique: true
			String :email, null: false, unique: true
			String :token_hash, null: false

			String :role, null: false, default: "member"
			TrueClass :active, null: false, default: true

			DateTime :created_at, null: false
		end
	end
end