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

		# request specs from the 'get_specs' method of this class.
		specs = get_specs(type)

		compressed_file = SecureRandom.hex(6) + '.' + specs[0]

		puts "Compressing against #{type} specs - Format:'#{specs[0]}',Quality'#{specs[1]}',Resize'#{specs[2]}'"
		image = MiniMagick::Image.open("./compression/#{file}.png")
		
		# pass the specs to the minimagick gem
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

		# this method supplies different specs of the compression operation based on what is passed to it.
		# this returns an array to the caller with the following parameters:
		# [#format_of_output, #quality_of_compression, #resize_percentage]

		if type == 'thumbnail'
			specs = ['jpg', '50', '40%']
			return specs
		end

		if type == 'web'
			specs = ['jpg', '50', '100%']
			return specs
		end

	end

end
