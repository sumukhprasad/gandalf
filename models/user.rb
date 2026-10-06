require "sequel"

class User < Sequel::Model(:users)
	many_to_many :groups, join_table: :memberships
	one_to_many :claims
	
	def password_set?
		token_hash == ""
	end
end