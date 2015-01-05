class Portfolio < ActiveRecord::Base
	DB_CONFIG = YAML::load(File.open('./config/database.yml'))
	establish_connection ("mysql2://root:Password1@192.168.1.91:3306/client")
	self.table_name = "portfolio"
	self.inheritance_column = :_type_disabled
end