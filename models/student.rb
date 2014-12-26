class Student < ActiveRecord::Base
	self.table_name = "student"
	self.inheritance_column = :_type_disabled
end