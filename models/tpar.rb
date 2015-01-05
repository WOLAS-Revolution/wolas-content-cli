class TPAR < ActiveRecord::Base
	DB_CONFIG = YAML::load(File.open('./config/database.yml'))
	establish_connection ("mysql2://root:a97m2o4h3lck@127.0.0.1:3306/tpar")
	self.table_name = "tpar"
	self.inheritance_column = :_type_disabled
end