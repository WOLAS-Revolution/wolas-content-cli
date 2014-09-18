class Thumbnail
	#require gems & libraries
	require 'securerandom'
	require 'aws-sdk'
	require 'yaml'
	require 'active_record'
 	require 'mysql2'
 	require 'mini_magick'

 	#require active record models
 	require './models/content.rb'

 	require './check_existence.rb'

 	DB_CONFIG = YAML::load(File.open('./config/database.yml'))
	ActiveRecord::Base.establish_connection("mysql2://#{DB_CONFIG['username']}:#{DB_CONFIG['password']}@#{DB_CONFIG['host']}:#{DB_CONFIG['port']}/#{DB_CONFIG['database']}")

	def setup
		AWS.config(YAML.load_file('./config/aws-s3.yaml'))
		s3 = AWS::S3.new
		@learning_original = s3.buckets['learningoriginal'] 
		@thumbnail_bucket = s3.buckets['learningthumb'] 
	end

	def find
		unq = Content.where("thumbnail = 'default.png' and type = 'Graphic' and id")
		puts "There are #{unq.count} pieces of content that do not have thumbnails."

		unq.each do |record|
			if CheckExistence.check('learningoriginal', record.original) == true
				puts "Beginning compression process for content #{record.id}."
				thumbnail = compress(record.original)
				puts "Updating database with newly compressed thumbnail for record #{record.id}."
				Content.update(record.id, :thumbnail => thumbnail)
				puts 'Finished.'
			else
				puts "The destination file #{record.id} was not found on s3. Skipping this file."
			end
		end
	end

	def compress(key)
		newthumbnail = SecureRandom.hex(6) + '.jpg'

		# read an object from S3 to a file
		File.open('./output.png', 'wb') do |file|
		  @learning_original.objects[key].read do |chunk|
		    file.write(chunk)
		  end
		end

		original_size = File.size('app/images/compress/output.png') / 1024.00

		puts "Commencing compression of file '#{key}' (#{original_size.floor}kb)."

		image = MiniMagick::Image.open("app/images/compress/output.png") 

		image.format "jpg"
		image.quality "50"
		image.resize "40%"
		image.write "app/images/compress/#{newthumbnail}"

		compressed_size = File.size("app/images/compress/#{newthumbnail}") / 1024.00

		puts "Compression complete. New file is '#{newthumbnail}' (#{compressed_size.floor}kb)."

		compression_rate = ((original_size - compressed_size)/original_size) * 100

		puts "The file was reduced by #{compression_rate.floor}%."
		
		##send object to S3 bucket

		puts "Uploading new thumbnail (#{newthumbnail}) to s3 bucket."

		obj = @thumbnail_bucket.objects["#{newthumbnail}"]
		obj.write(Pathname.new("app/images/compress/#{newthumbnail}"))

		FileUtils.rm_rf(Dir.glob('app/images/compress/*'))

		return newthumbnail
	end

end
