class Address < ActiveRecord::Base
	self.table_name = "address"
	self.inheritance_column = :_type_disabled
end