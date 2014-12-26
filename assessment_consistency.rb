class AssessmentConsistency

 	# require active record models.
 	require './models/assessment.rb'
 	require './models/item.rb'
 	require './models/group.rb'
 	require './models/item_group.rb'
 	require './models/item_stack.rb'
 	require './models/stack.rb'
 	require './models/enrol.rb'
 	require './models/submission.rb'
 	require './models/answer.rb'

 	# expose the ActiveRecord operations to the command line so we can see how we are interfacing with our databases.
 	#ActiveRecord::Base.logger = Logger.new(STDOUT)

 	DB_CONFIG = YAML::load(File.open('./config/database.yml'))
	ActiveRecord::Base.establish_connection("mysql2://#{DB_CONFIG['username']}:#{DB_CONFIG['password']}@#{DB_CONFIG['host']}:#{DB_CONFIG['port']}/#{DB_CONFIG['database']}")

	def commence

		all_assessments = Assessment.all
		puts "#{all_assessments.count} assessment records found. Commencing."
		sleep (2)

		# global array for holding all the error messages found.
		@error_messages = []

		puts 'Running Tests'

		all_assessments.each_with_index do |assessment,index|
			puts "#{index + 1} out of #{all_assessments.count}"
			part1(assessment) # run assessment count check.
			part2(assessment) # run duplicate items inside stack and group check
			part3(assessment)
			part4(assessment)
		end

		puts @error_messages
		puts "**** COMPLETED **** #{@error_messages.count} ERRORS."

	end

	def part1(assessment)

		@items_from_group = []
		
		# gather all the itemIDs for the assessment via item_group link table.
		assessment.item_groups.each do |group|
			@items_from_group << group.itemID
		end

		# gather all the itemIDs for the assessment via stack link table.
		@items_from_stack = []
		stacks = assessment.stacks.includes(:item)

		stacks.each do |stack|
			# some stack items are linked to pieces of learning content, so we need to check for null.
			if !stack.item.nil?
				@items_from_stack << stack.item.id
			end
		end

		# we have the itemIDs on both sides of the assessment, we now need to validate to see if there is the same 
		# amount of itemIDs as in the stack and the group.

		if @items_from_group.length != @items_from_stack.length
			@error_messages << "ASSESSMENT #{assessment.id} - COUNTS CHECK FAILED - Items in group: #{@items_from_group.length}. Items in stack #{@items_from_stack.length}."
		end

	end

	def part2(assessment)
		
		# here we are checking duplicate items inside the stack & inside the group.
		# This first test is very important because if it fails it will almost certainly cause further errors with the assessment.

		duplicate_stacks = @items_from_stack.find_all { |e| @items_from_stack.count(e) > 1 }
		duplicate_group =@items_from_group.find_all { |e| @items_from_group.count(e) > 1 }

		if duplicate_stacks.length > 0
			@error_messages << "ASSESSMENT #{assessment.id} - DUPLICATE CHECK FAILED - Duplicate Items ((#{duplicate_stacks.count})) in the stack. (#{duplicate_stacks})"
		end

		if duplicate_group.length > 0
			@error_messages << "ASSESSMENT #{assessment.id} - DUPLICATE CHECK FAILED - Duplicate Items (#{duplicate_group.count}) in the group.(#{duplicate_group})"
		end

	end

	def part3(assessment)

		# we have the itemIDs on both sides of the assessment, we now need to validate to see if the item id's
		# match up between the stack and the groups. Its important these match up so that we can be sure
		# the correct assessment items are being delivered to the student.

		# Check from the group side

		@items_from_group.each  do  |groupitem|
			if !@items_from_stack.include? groupitem
				@error_messages << "ASSESSMENT #{assessment.id} - INTEGRITY CHECK FAILED - Item #{groupitem} does not exist in any assessment stack, but does exist in the group."
			end
		end
 	
		# Check from the stack side

		@items_from_stack.each do |stackitem| 
			if !@items_from_group.include? stackitem
				@error_messages << "ASSESSMENT #{assessment.id} - INTEGRITY CHECK FAILED - Item #{stackitem} does not exist in any assessment group, but does exist in the stack."
			end
		end

	end

	def part4(assessment)

		# takes 5 random completed assessments done by students and compares the itemIDs within their submissions
		# to the itemIDs within the assessment stack.

		enrolments = Enrol.where("assessmentID = #{assessment.id}")

		items_in_submission = []

		if enrolments.length > 0
			
			# 10.times do

			enrolments.each do |enrolment|
				# take a random enrolment 
				#enrolment = enrolments.sample
				submissions = Submission.includes(:answer).where("assessmentID = #{assessment.id} AND lifeID = #{enrolment.lifeID}")

				submissions.each do |s|
					# not all submissions are for items (in old assessments), we check for null.
					if s.answer
						# add items into array if they aren't already in there
						items_in_submission << s.answer.itemID unless items_in_submission.include? s.answer.itemID
					end
				end
			end
			# end

			# check if item exists within the current items in the stack.
			items_in_submission.each do |answer_item|
				if !@items_from_stack.include? answer_item.to_i
					@error_messages << "ASSESSMENT #{assessment.id} - SUBMISSION LOOPBACK CHECK FAILED - Item #{answer_item} answer found in a students answer for this assessment but doesn't exist in the assessment stack."	
				end
			end
		end

	end	
end