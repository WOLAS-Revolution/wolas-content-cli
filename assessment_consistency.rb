

class AssessmentConsistency


 	# require active record models.
 	require './models/assessment.rb'
 	require './models/item.rb'
 	require './models/group.rb'
 	require './models/item_group.rb'
 	require './models/item_stack.rb'
 	require './models/stack.rb'

 	# expose the ActiveRecord operations to the command line so we can see how we are interfacing with our databases.
 	ActiveRecord::Base.logger = Logger.new(STDOUT)

 	DB_CONFIG = YAML::load(File.open('./config/database.yml'))
	ActiveRecord::Base.establish_connection("mysql2://#{DB_CONFIG['username']}:#{DB_CONFIG['password']}@#{DB_CONFIG['host']}:#{DB_CONFIG['port']}/#{DB_CONFIG['database']}")

	def commence 

		# loop through each assessment
			# get all the item_stack items 
			# get all the item_group items
			# count both and ensure they are the same.

		# loop through the item stack and see if the item ids exist within the item_group of that assessment.


	puts 'Commencing assessment consisistency checks.'
	

	all_assessments = Assessment.where("id = 5630048")

	puts "#{all_assessments.count} assessment records found. Commencing."

	sleep (2)
	error_messages = []

	all_assessments.each do |assessment|

		## gets all items within item group
		items_from_group = []
		
		groups = assessment.item_groups
		groups.each do |group|
			items_from_group << group.itemID
		end

		## gets all items with item stack
		items_from_stack = []
		stacks = assessment.stacks


		stacks.each do |stack|
			# check if an item  is linked to the stack.
			# stacks can either be linked to items or content

			if !stack.item.nil?
				# stack is linked to an item. store this item id.
				items_from_stack << stack.item.id
			end

		end

		# finally we want to compare the counts to ensure the same amount of items exist within the
		# assessment stack and the assessment groups.

		if items_from_group.length != items_from_stack.length
			puts items_from_group
			puts '---'
			puts items_from_stack
			error_messages << "ASSESSMENT #{assessment.id} - COUNTS CHECK FAILED - Items in group: #{items_from_group.length}. Items in stack #{items_from_stack.length}."
		end

		## commence integrity checks
		errors = 0

		items_from_group.each  do  |groupitem|
			if !items_from_stack.include? groupitem
				error_messages << "ASSESSMENT #{assessment.id} - INTEGRITY CHECK FAILED - Item #{groupitem} does not exist in any assessment stack, but does exist in the group."
			end
		end
 
		items_from_stack.each do |stackitem| 
			if !items_from_group.include? stackitem
				error_messages << "ASSESSMENT #{assessment.id} - INTEGRITY CHECK FAILED - Item #{stackitem} does not exist in any assessment group, but does exist in the stack."
			end
		end

		# ####### FIND DUPLICATES

		# puts 'here'
		# puts items_from_group.detect{ |e| items_from_group.count(e) > 1 }
		# puts 'here'
		# puts items_from_stack.detect{ |e| items_from_stack.count(e) > 1 }

		# ## commence duplicate check
		# if !items_from_stack.uniq.length == items_from_stack.length
		# 	error_messages << "ASSESSMENT #{assessment.id} - DUPLICATE CHECK FAILED - Duplicate Items in the stack."
		# end

		# if !items_from_group.uniq.length == items_from_group.length
		# 	error_messages << "ASSESSMENT #{assessment.id} - DUPLICATE CHECK FAILED - Duplicate Items in the group."
		# end


		######## CONSISTENCY CHECK

		 answer_items = "21301,
			21473,
			21304,
			21303,
			21302,
			21323,
			21297,
			21298,
			21299,
			21313,
			21305,
			21308,
			21306,
			21307,
			21310,
			21309,
			21312,
			21316,
			21317,
			21318,
			21300,
			21314,
			21311,
			21315,
			21320,
			21319,
			21334,
			21328,
			21329,
			21331,
			21330,
			21470,
			21474,
			21333,
			21472,
			21471,
			21335,
			21322,
			21326,
			21325,
			21332"

		final = answer_items.split(',')
		## loop through all items in assessment.

		# check if item is in final answer
		final.each do |answer_item|
			if !items_from_group.include? answer_item.to_i
				error_messages << "ASSESSMENT #{assessment.id} - CONSISTENCY CHECK FAILED - Item #{answer_item} answer found but doesn't exist in the group."	
			end
		end
	end

	puts error_messages

	end	
end