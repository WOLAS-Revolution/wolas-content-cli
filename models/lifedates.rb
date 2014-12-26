class LifeDates < ActiveRecord::Base
	self.table_name = "lifeDates"
	self.inheritance_column = :_type_disabled
end