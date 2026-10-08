require "sinatra/base"

require_relative "config/database"
require_relative "models/user"
require_relative "models/group"
require_relative "models/membership"
require_relative "models/claim"
require_relative "models/assignment"
require_relative "models/verification"
require_relative "models/verification_issue"
require_relative "models/verification_source"


require_relative "lib/assignments"

if User.all == []
	User.create(
		username: "admin",
		email: "admin@example.com",
		token_hash: "",
		role: "admin",
		created_at: Time.now
	)
	
	puts "A new default admin user was created!"
end

class Gandalf < Sinatra::Base
	set :environment, ENV.fetch("RACK_ENV", "development").to_sym
	set :views, File.expand_path("views", __dir__)
	set :public_folder, File.expand_path("public", __dir__)
	enable :sessions
	set :session_secret, ENV.fetch('SESSION_SECRET')
	
	before do
		@current_user = User[session[:user_id]] if session[:user_id]
	end
	
	# not the most secure, but eh it works.
	def self.configure_routes(&block)
		class_eval(&block)
	end
	Dir[File.join(__dir__, "routes", "*.rb")].each do |route_file|
		class_eval(File.read(route_file), route_file)
	end
end
