class Staff < ActiveRecord::Base
	self.table_name = "staff"
	self.inheritance_column = :_type_disabled
end