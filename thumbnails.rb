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
		@original_bucket = s3.buckets['learningoriginal'] 
		@thumbnail_bucket = s3.buckets['learningthumb'] 
	end

	def find
		#unq = Content.where("thumbnail = 'default.png' and type = 'Graphic'")
		unq = Content.where("id = 203")
		puts "There are #{unq.count} pieces of content that do not have thumbnails."

		unq.each do |record|
			if CheckExistence.new.check('learningoriginal', record.original) == true
				puts "Beginning compression process for content #{record.id}."
				thumbnail = compress(record.original)
				#puts "Updating database with newly compressed thumbnail for record #{record.id}."
				#Content.update(record.id, :thumbnail => thumbnail)
				puts 'Finished.'
			elsif CheckExistence.new.check('learningoriginal', record.original) == false
				puts "The destination file #{record.id} (#{record.original}) was not found on s3. Skipping this file."
			else
				puts "There was an error interfacing with s3 to check if the objects exists."
			end
		end
	end

	def compress(key)
		# generate a unique file name for the file we want to compress.
		original_file = SecureRandom.hex(6) + '.jpg'

		# download the file off s3 to a local directory, name it the hex we created above.
		File.open("./compression/#{original_file}.png", 'wb') do |file|
		  @original_bucket.objects[key].read do |chunk|
		    file.write(chunk)
		  end
		end

		# kick off the compression
		compressed_file = ImageCompress.new.compress(original_file, 'thumbnail')

		# send compressed file to S3 bucket
		puts "Uploading new thumbnail (#{compressed_file}) to s3 bucket."

		obj = @thumbnail_bucket.objects["#{compressed_file}"]
		obj.write(Pathname.new("./compression/#{compressed_file}"))

	end


end
