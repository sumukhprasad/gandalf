Sequel.migration do
	change do
		create_table(:verification_sources) do
			primary_key :id

			foreign_key :verification_id, :verifications, null: false

			String :url, text: true
			String :title, null: false
			String :author

			DateTime :published_at

			String :source_type, null: false, default: "other"
			String :relation, null: false, default: "neutral"

			String :excerpt, text: true
			String :location, text: true
			String :relevance, text: true

			DateTime :created_at, null: false
		end

		add_index :verification_sources, :verification_id
	end
end