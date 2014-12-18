class Item < ActiveRecord::Base
	self.table_name = "item"
	self.inheritance_column = :_type_disabled
end
