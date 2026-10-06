require "sequel"

class Group < Sequel::Model(:groups)
	one_to_many :memberships
	one_to_many :claims
	many_to_many :users, join_table: :memberships
end