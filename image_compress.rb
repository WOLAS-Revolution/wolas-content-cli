class ImageCompress

	#require gems & libraries.
	require 'securerandom'
 	require 'mini_magick'

	def compress(file,type)
		# calculate the initial size of the file prior to compression.
		original_size = File.size("./compression/#{file}.png") / 1024.00
		puts "Commencing compression of file '#{file}' (#{original_size.floor}kb)."

		# commence compression of file locally the initial size of the file.
		# create a new file (not compressed inline) with a random hex name.

		compressed_file = SecureRandom.hex(6) + '.jpg'
		image = MiniMagick::Image.open("./compression/#{file}.png")

		if type == 'thumbnail'
			specs = get_specs('thumbnail')
		end

		image.format specs[0]
		image.quality specs[1]
		image.resize specs[2]
		image.write "./compression/#{compressed_file}"

		# calculate the size of the compressed file prior to compression.
		compressed_size = File.size("./compression/#{compressed_file}") / 1024.00
		puts "Compression complete. New file is '#{compressed_file}' (#{compressed_size.floor}kb)."

		# compute the percentage reduction in size pre and post compression.
		compression_rate = ((original_size - compressed_size)/original_size) * 100
		puts "The file was reduced by #{compression_rate.floor}%."

		return compressed_file
	end

	def get_specs(type)

		if type == 'thumbnail'
			specs = ['jpg', '50', '40%']
			return specs
		end

		if type == 'web'
			specs = ['jpg', '50', '40%']
			return specs
		end

	end

end
