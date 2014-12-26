class Enrol < ActiveRecord::Base
	self.table_name = "enrol"
	self.inheritance_column = :_type_disabled
end