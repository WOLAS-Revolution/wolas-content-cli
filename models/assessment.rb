class Assessment < ActiveRecord::Base
	self.table_name = "assessment"
	self.inheritance_column = :_type_disabled
	
	has_many :item_groups, foreign_key: "assessmentID"
	has_many :stacks, foreign_key: "assessmentID"

end

