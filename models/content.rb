class Content < ActiveRecord::Base
	self.table_name = "content"
	self.inheritance_column = :_type_disabled
end
