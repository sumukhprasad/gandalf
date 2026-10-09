Sequel.migration do
	change do
		alter_table(:verifications) do
			add_column :accepted_at, DateTime
			add_foreign_key :accepted_by, :users
		end
	end
end