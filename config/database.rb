require "sequel"
require "fileutils"

db_path = ENV.fetch(
	"DATABASE_PATH",
	File.expand_path("../db/gandalf.sqlite3", __dir__)
)

FileUtils.mkdir_p(File.dirname(db_path))

DB = Sequel.sqlite(db_path)

DB.run("PRAGMA foreign_keys = ON")
DB.run("PRAGMA journal_mode = WAL")