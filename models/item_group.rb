class ItemGroup < ActiveRecord::Base
	self.table_name = "item_group"
	self.inheritance_column = :_type_disabled
end
