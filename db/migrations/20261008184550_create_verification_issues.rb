Sequel.migration do
	change do
		create_table(:verification_issues) do
			primary_key :id

			foreign_key :verification_id, :verifications, null: false

			String :issue, null: false
			String :details, text: true

			DateTime :created_at, null: false
		end

		add_index :verification_issues, :verification_id
		add_index :verification_issues, :issue
	end
end