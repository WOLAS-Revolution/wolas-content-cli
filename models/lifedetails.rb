class LifeDetails < ActiveRecord::Base
	self.table_name = "lifeDetails"
	self.inheritance_column = :_type_disabled
end