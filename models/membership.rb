require "sequel"

class Membership < Sequel::Model(:memberships)
	many_to_one :group
	many_to_one :user
end