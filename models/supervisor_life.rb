class SupervisorLife < ActiveRecord::Base
	self.table_name = "supervisor_life"
	self.inheritance_column = :_type_disabled
end	