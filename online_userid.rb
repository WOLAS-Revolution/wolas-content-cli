class OnlineUserID < ActiveRecord::Base
	self.table_name = "onliner_userID"
	self.inheritance_column = :_type_disabled
end