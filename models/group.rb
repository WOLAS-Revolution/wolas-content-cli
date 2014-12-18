class itemGroup < ActiveRecord::Base
	self.table_name = "group"
	self.inheritance_column = :_type_disabled
end
