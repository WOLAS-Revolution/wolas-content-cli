class Business < ActiveRecord::Base
	self.table_name = "Business"
	self.inheritance_column = :_type_disabled
end