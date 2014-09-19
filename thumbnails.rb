class Thumbnail
	# require gems & libraries.
	require 'securerandom'
	require 'aws-sdk'
	require 'yaml'
	require 'active_record'
 	require 'mysql2'

 	# require active record models.
 	require './models/content.rb'

 	# require any classes that are needed.
 	require './check_existence.rb'
 	require './image_compress.rb'

 	# expose the ActiveRecord operations to the command line so we can see how we are interfacing with our databases.
 	ActiveRecord::Base.logger = Logger.new(STDOUT)

 	DB_CONFIG = YAML::load(File.open('./config/database.yml'))
	ActiveRecord::Base.establish_connection("mysql2://#{DB_CONFIG['username']}:#{DB_CONFIG['password']}@#{DB_CONFIG['host']}:#{DB_CONFIG['port']}/#{DB_CONFIG['database']}")

	def setup
		# complete initial setup for the script to run. Enter AWS credentials, and the buckets required.
		AWS.config(YAML.load_file('./config/aws-s3.yaml'))
		s3 = AWS::S3.new

		@source_bucket = 'learningoriginal'
		@desintation_bucket = 'learningcontent'

		@bucket_in = s3.buckets[@source_bucket] 
		@bucket_out = s3.buckets[@desintation_bucket]
		@compression_type = 'web'

		@out_entity = :web

	end


	def find
		unq = Content.where("web IS NULL and type = 'Graphic'")

		puts "There are #{unq.count} pieces of content that will be compressed."

		unq.each do |record|

			# lets check to see if the original file exists in s3, if it does, commence compression.
			puts "Checking if '#{record.original}' exists in '#{@source_bucket}' bucket"
			 if CheckExistence.new.check(@source_bucket, record.original) == true
			 	puts "Located '#{record.original}' file."
			 	puts "Beginning compression process for content #{record.id}."
			 	compressed_filename = send_for_compression(record.original)
			 	puts "Updating #{@out_entity} record in database with newly compressed file for record #{record.id}."
			 	Content.update(record.id, @out_entity => compressed_filename)
			 	puts 'Finished.'
			 elsif CheckExistence.new.check(@source_bucket, record.original) == false
			 	puts "The destination file #{record.id} (#{record.original}) was not found on s3. Skipping this file."
			 else
			 	puts "There was an error interfacing with s3 to check if the objects exists."
			end
		end
	end

	def send_for_compression(key)
		# generate a unique file name for the file we want to compress.
		original_file = SecureRandom.hex(6)

		# download the file off s3 to a local directory, name it the hex we created above.
		File.open("./compression/#{original_file}.png", 'wb') do |file|
		  @bucket_in.objects[key].read do |chunk|
		    file.write(chunk)
		  end
		end

		# kick off the compression using our imagecompression class,
		# we pass the file that we want compressed as well as type of compression
		# (this is used to determine compression settings.)
		compressed_file = ImageCompress.new.compress(original_file, @compression_type)

		# # send compressed file to S3 bucket.
		puts "Uploading new file (#{compressed_file}) to s3 bucket(#{@desintation_bucket})."
		obj = @bucket_out.objects["#{compressed_file}"]
		obj.write(Pathname.new("./compression/#{compressed_file}"))

		puts 'Upload Complete.'
		return compressed_file

	end


end
