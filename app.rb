require "sinatra/base"

class Gandalf < Sinatra::Base
	set :environment, ENV.fetch("RACK_ENV", "development").to_sym
	set :views, File.expand_path("views", __dir__)
	set :public_folder, File.expand_path("public", __dir__)
	
	get "/" do
		erb :home
	end

	get "/health" do
		content_type :text
		"gandalf is alive"
	end
end
