class SupervisorLife < ActiveRecord::Base
	DB_CONFIG = YAML::load(File.open('./config/database.yml'))
	establish_connection ("mysql2://root:Password1@192.168.1.91:3306/customer")
	self.table_name = "supervisor_life"
	self.inheritance_column = :_type_disabled
end	