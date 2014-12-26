class Avetmiss < ActiveRecord::Base
	self.table_name = "avetmiss"
	self.inheritance_column = :_type_disabled
end