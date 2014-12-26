class Stack < ActiveRecord::Base
	self.table_name = "stack"
	self.inheritance_column = :_type_disabled

	has_one :item_stack, foreign_key: "stackID"
	has_one :item, :through => :item_stack


end