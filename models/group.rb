require "sequel"

class Group < Sequel::Model(:groups)
	one_to_many :memberships
	many_to_many :users, join_table: :memberships
end