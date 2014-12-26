class Activity < ActiveRecord::Base
	self.table_name = "activity"
	self.inheritance_column = :_type_disabled
end