require "sequel"

class User < Sequel::Model(:users)
	many_to_many :groups, join_table: :memberships
	
	
	def password_set?
		token_hash == ""
	end
end