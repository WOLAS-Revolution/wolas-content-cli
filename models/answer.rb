class Answer < ActiveRecord::Base
	DB_CONFIG = YAML::load(File.open('./config/database.yml'))
	establish_connection ("mysql2://#{DB_CONFIG['username']}:#{DB_CONFIG['password']}@#{DB_CONFIG['host']}:#{DB_CONFIG['port']}/client")
	self.table_name = "answer"
	self.inheritance_column = :_type_disabled
end
