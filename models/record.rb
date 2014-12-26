class Record < ActiveRecord::Base
	self.table_name = "record"
	self.inheritance_column = :_type_disabled
end