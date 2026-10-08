require "sequel"

class Assignment < Sequel::Model
	many_to_one :claim
	many_to_one :verifier, class: :User, key: :verifier_id
	many_to_one :creator, class: :User, key: :created_by
	one_to_one :verification

	dataset_module do
		def active
			where(status: "active")
		end

		def completed
			where(status: "completed")
		end

		def rescinded
			where(status: "rescinded")
		end
	end
end