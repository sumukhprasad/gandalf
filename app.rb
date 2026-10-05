require "sinatra/base"

require_relative "config/database"
require_relative "models/user"

class Gandalf < Sinatra::Base
	set :environment, ENV.fetch("RACK_ENV", "development").to_sym
	set :views, File.expand_path("views", __dir__)
	set :public_folder, File.expand_path("public", __dir__)
	enable :sessions
	
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
