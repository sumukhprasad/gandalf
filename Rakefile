require "rake"
require "sequel"
require "sequel/extensions/migration"

require_relative "config/database"

namespace :db do
	task :migrate do
		Sequel::Migrator.run(DB, "db/migrations")
	end
end