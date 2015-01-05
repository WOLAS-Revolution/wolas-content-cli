# require gems & libraries.
require 'yaml' #gem install yaml
require 'active_record' #gem install active_record
require 'mysql2' #gem install yaml

require './models/assessment.rb'

DB_CONFIG = YAML::load(File.open('./config/database.yml'))
ActiveRecord::Base.establish_connection("mysql2://root:Password1@192.168.1.91:3306/assessment")

puts 'Beginning...'

date = DateTime.now - 1.day

# select all of the assessments
assessments = Assessment.where.not(released: nil)
puts "Total number of assessments found: #{assessments.length}"

# var the two assessment types to seperate the loops.
tas_assessments = assessments.select{ |a| a.type == "TAS" }
rpl_assessments = assessments.select{ |a| a.type == "RPL" }

# loop each rpl assessment
rpl_count = 1
rpl_assessments.each do |ass|
	puts "Updating assessment_id: #{ass.id}"

	# attempt to locate any other versions of the current unit_id
	testing_assessments = rpl_assessments.select{ |a| a.unitID == ass.unitID }

	if testing_assessments.length > 1

		puts 'Found the following versions under the same unit_id'

		testing_assessments.each do |a|
			puts "version #{a.version}"
		end

		# find the highest version to update the release date
		highest_version = testing_assessments.sort_by{
			|a| a.version
		}.reverse[0]

		puts "Highest version found is #{highest_version.version}"
		puts "Updating assessment_id #{highest_verison.id} now"

		# update the highest versions' assessment release date.
		Assessment.update(highest_version.id, released: date, releasedBy: "Scriped version control")

	else
		puts 'Single assessment found under the unit_id'

		puts "Updating assessment_id #{ass.id} now"
		# update the current assessments release date
		Assessment.update(ass.id, released: date, releasedBy: "Scripted version control")

	end

	puts "Completed #{rpl_count}/#{rpl_assessments.length} RPL assessments."
	rpl_count = rpl_count + 1
end

tas_count = 1
tas_assessments.each do |ass|
	puts "Updating assessment_id: #{ass.id}"

	# attempt to locate any other versions of the current unit_id
	testing_assessments = tas_assessments.select{ |a| a.unitID == ass.unitID }

	if testing_assessments.length > 1
		puts 'Found the following versions under the same unit_id'

		testing_assessments.each do |a|
			puts "version #{a.version}"
		end

		# find the highest version to update the release date.
		highest_version = testing_assessments.sort_by{
			|a| a.version
		}.reverse[0]

		puts "Highest version found is #{highest_version.version}"
		puts "Updating assessment_id #{highest_version.id} now"

		# update the highest versions' assessment release date.
		Assessment.update(highest_version.id, released: date, releasedBy: "Scripted version control")
	else
		puts 'Single assessment found under the unit_id'

		puts "Updating assessment_id #{ass.id} now"
		Assessment.update(ass.id, released: date, releasedBy: "Scripted version control")

	end

	puts "Completed #{tas_count}/#{tas_assessments.length} TAS assessments."
	tas_count = tas_count + 1
end

puts 'Completed.'