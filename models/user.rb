require "sequel"

class User < Sequel::Model(:users)
	def password_set?
		token_hash == ""
	end
end