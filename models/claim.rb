require "sequel"

class Claim < Sequel::Model(:claims)
	many_to_one :group
	many_to_one :user
	
	STATUSES = %w[pending assigned completed cancelled].freeze
end