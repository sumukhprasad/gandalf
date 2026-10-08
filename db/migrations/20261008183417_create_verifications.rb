Sequel.migration do
	change do
		create_table(:verifications) do
			primary_key :id

			foreign_key :assignment_id, :assignments, null: false, unique: true

			String :verdict, null: false, default: "inconclusive"
			String :confidence, null: false, default: "medium"

			String :interpreted_claim, text: true, null: false
			String :explanation, text: true, null: false

			String :assumptions, text: true
			String :limitations, text: true

			DateTime :submitted_at, null: false
			DateTime :updated_at, null: false
		end

		add_index :verifications, :verdict
	end
end