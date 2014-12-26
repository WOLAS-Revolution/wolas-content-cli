class LifeActivity < ActiveRecord::Base
	self.table_name = "life_activity"
	self.inheritance_column = :_type_disabled
end