class Contact < ActiveRecord::Base
	self.table_name = "contact"
	self.inheritance_column = :_type_disabled
end