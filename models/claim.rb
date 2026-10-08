require "sequel"

class Claim < Sequel::Model(:claims)
	many_to_one :group
	many_to_one :user
	one_to_many :assignments
	
	STATUSES = %w[pending assigned completed cancelled].freeze
	


	def active_assignment
		assignments_dataset.where(status: "active").first
	end
end