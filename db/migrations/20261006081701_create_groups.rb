Sequel.migration do
	change do
		create_table(:groups) do
			primary_key :id

			String :name, null: false, unique: true
			String :slug, null: false, unique: true

			DateTime :created_at, null: false
		end
	end
end