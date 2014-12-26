class User < ActiveRecord::Base
	self.table_name = "user"
	self.inheritance_column = :_type_disabled
end