class Thumbnail
	#require gems & libraries.
	require 'securerandom'
	require 'aws-sdk'
	require 'yaml'
	require 'active_record'
 	require 'mysql2'
 	require 'mini_magick'

 	#require active record models.
 	require './models/content.rb'

 	#require any classes that are needed.
 	require './check_existence.rb'

 	#expose the ActiveRecord operations to the command line so we can see how we are interfacing with our databases.
 	ActiveRecord::Base.logger = Logger.new(STDOUT)

 	DB_CONFIG = YAML::load(File.open('./config/database.yml'))
	ActiveRecord::Base.establish_connection("mysql2://#{DB_CONFIG['username']}:#{DB_CONFIG['password']}@#{DB_CONFIG['host']}:#{DB_CONFIG['port']}/#{DB_CONFIG['database']}")

	def setup
		#complete initial setup for the script to run. Enter AWS credentials, and the buckets required.
		AWS.config(YAML.load_file('./config/aws-s3.yaml'))
		s3 = AWS::S3.new
		@original_bucket = s3.buckets['learningoriginal'] 
		@thumbnail_bucket = s3.buckets['learningthumb'] 
	end

	def find
		unq = Content.where("thumbnail = 'default.png' and type = 'Graphic'").limit(1)
		puts "There are #{unq.count} pieces of content that do not have thumbnails."

		unq.each do |record|
			if CheckExistence.new.check('learningoriginal', record.original) == true
				puts "Beginning compression process for content #{record.id}."
				thumbnail = compress(record.original)
				puts "Updating database with newly compressed thumbnail for record #{record.id}."
				Content.update(record.id, :thumbnail => thumbnail)
				puts 'Finished.'
			elsif CheckExistence.new.check('learningoriginal', record.original) == false
				puts "The destination file #{record.id} (#{record.original}) was not found on s3. Skipping this file."
			else
				puts "There was an error interfacing with s3 to check if the objects exists."
			end
		end
	end

	def compress(key)

		# download the file off s3 to a local directory.
		File.open('./compression/output.png', 'wb') do |file|
		  @original_bucket.objects[key].read do |chunk|
		    file.write(chunk)
		  end
		end

		# calculate the initial size of the file prior to compression.
		original_size = File.size('./compression/output.png') / 1024.00
		puts "Commencing compression of file '#{key}' (#{original_size.floor}kb)."

		# commence compression of file locally the initial size of the file.
		# create a new file (not compressed inline) with a random hex name.

		newthumbnail = SecureRandom.hex(6) + '.jpg'
		image = MiniMagick::Image.open("./compression/output.png") 

		image.format "jpg"
		image.quality "50"
		image.resize "40%"
		image.write "./compression/#{newthumbnail}"

		# calculate the size of the compressed file prior to compression.
		compressed_size = File.size("./compression/#{newthumbnail}") / 1024.00
		puts "Compression complete. New file is '#{newthumbnail}' (#{compressed_size.floor}kb)."

		# compute the percentage reduction in size pre and post compression.
		compression_rate = ((original_size - compressed_size)/original_size) * 100
		puts "The file was reduced by #{compression_rate.floor}%."
		
		# send object to S3 bucket
		puts "Uploading new thumbnail (#{newthumbnail}) to s3 bucket."

		obj = @thumbnail_bucket.objects["#{newthumbnail}"]
		obj.write(Pathname.new("./compression/#{newthumbnail}"))

		FileUtils.rm_rf(Dir.glob('./compression/*'))

		return newthumbnail

	end
end
