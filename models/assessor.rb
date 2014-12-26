class Assessor < ActiveRecord::Base
	self.table_name = "assessor"
	self.inheritance_column = :_type_disabled
end