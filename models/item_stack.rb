class ItemStack < ActiveRecord::Base
	self.table_name = "item_stack"
	self.inheritance_column = :_type_disabled

	belongs_to :item, foreign_key: "itemID"
	belongs_to :stack, foreign_key: "stackID"
end