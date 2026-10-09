Sequel.migration do
	change do
		create_table(:email_jobs) do
			primary_key :id

			String :recipient, null: false
			String :kind, null: false
			String :payload, text: true, null: false

			String :status, null: false, default: "pending"
			Integer :attempts, null: false, default: 0

			DateTime :available_at, null: false
			DateTime :created_at, null: false
			DateTime :sent_at
			DateTime :locked_at

			String :last_error, text: true
		end

		add_index :email_jobs, [:status, :available_at]
	end
end