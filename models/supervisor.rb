class Supervisor < ActiveRecord::Base
	self.table_name = "supervisor"
	self.inheritance_column = :_type_disabled
end