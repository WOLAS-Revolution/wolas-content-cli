class LifeDetails < ActiveRecord::Base
	DB_CONFIG = YAML::load(File.open('./config/database.yml'))
	establish_connection ("mysql2://root:Password1@192.168.1.91:3306/customerExtended")
	self.table_name = "lifeDetails"
	self.inheritance_column = :_type_disabled
end