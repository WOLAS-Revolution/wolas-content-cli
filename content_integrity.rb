class ContentIntegrity

	# require gems & libraries.
	require 'yaml'
	require 'active_record'
 	require 'mysql2'
	require 'net/http'

 	# require active record models.
 	require './models/content.rb'

 	# require any classes that are needed.
 	require './check_existence.rb'



 	# expose the ActiveRecord operations to the command line so we can see how we are interfacing with our databases.
 	ActiveRecord::Base.logger = Logger.new(STDOUT)

 	DB_CONFIG = YAML::load(File.open('./config/database.yml'))
	ActiveRecord::Base.establish_connection("mysql2://#{DB_CONFIG['username']}:#{DB_CONFIG['password']}@#{DB_CONFIG['host']}:#{DB_CONFIG['port']}/#{DB_CONFIG['database']}")

	def set_scope

		# we will use a instance variable to collect all the issues that our checks uncover.
		# later on we will use this to give a report to the user.
		@missing = Array.new

		records_to_check = Content.all
		puts 'Commencing thumbnail check'
		#lets check that all of our thumbnails in our db exist in s3.
		check(:thumbnail,:learningthumb,records_to_check)

		records_to_check = Content.where("type <> 'link'")
		puts 'Commencing originals check'
		#lets check that all of our originals in our db exist in s3.
		check(:original,:learningoriginal,records_to_check)

		records_to_check = Content.where("type <> 'link'")
		puts 'Commencing web check'
		#lets check that all of our web versions in our db exist in s3.
		check(:web,:learningcontent,records_to_check)

		records_to_check = Content.where("type = 'link'")
		puts 'Commencing external checks'
		#lets check that all of our HTTP endpoints are healthy.
		ping(records_to_check)


		# lets check our missing variable. If there are any issues we want to tell the user.
		if @missing.count < 0 
			puts 'All content present and accounted for.'
		else
			puts 'We are missing content.'
			puts @missing
		end

		puts 'All checks complete.'

	end


	def check(entity, bucket, recordset)

		total_to_be_checked = recordset.count
		puts "There are #{total_to_be_checked} #{entity} pieces of content that will be checked."

		recordset.each_with_index do |record, index|
			puts "#{index + 1}/#{total_to_be_checked} checked. #{@missing.count} missing." 

			# lets check to see if the original file exists in s3.
			puts "Checking for content #{record.id}"
			if CheckExistence.new.check(bucket,record[entity]) != true
			 	puts "The destination #{entity} file was not found in s3 bucket #{bucket}. Noted."
			 	@missing << "#{entity} file '#{record[entity]}' missing from #{bucket} bucket."
			end
		end

	end

	def ping(recordset)

		# this method is used to check our external files that our system depends on for learning material.
		# we are going to hit every URL that we have, and ensure we receive a 200 response back
		# to ensure the endpoint is health.

		total_to_be_checked = recordset.count
		puts "There are #{total_to_be_checked} URLs to that will be checked for 200 response."

		recordset.each_with_index do |record, index|

			puts "#{index + 1}/#{total_to_be_checked} checked. #{@missing.count} missing." 

			begin
				
				# setup our NET::HTTP request, hit the URL.
				url = URI.parse(record.external)
				req = Net::HTTP.new(url.host, url.port)
				res = req.request_head(url.path)

				puts "Checking for content #{record.id}"

				# lets check for 200 status code the destination URL.

				if res.code != '200'
					puts "The destination URL ('#{record.external}') returned status code '#{res.code}'"
				 	@missing << "#{record.external} returned status code '#{res.code}'."
			 	end
					
			rescue Exception => e
				# if URL was for some reason not able to be pinged, and thus no response.

				@missing << "#{record.external} URL was failed to be pinged. Check that its a valid address. ('#{e}')."
				
			end


		end
	end


end
