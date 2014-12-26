class TPAR < ActiveRecord::Base
	self.table_name = "tpar"
	self.inheritance_column = :_type_disabled
end