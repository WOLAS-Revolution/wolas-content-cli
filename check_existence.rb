require 'aws-sdk'

# This is a very simple class that simply checks for an s3 item in our
# S3 bucket repositories. It can be used for any filetype.

class CheckExistence
	def check (bucket, filename)
		AWS.config(YAML.load_file('./config/aws-s3.yaml'))

		s3 = AWS::S3.new
		bucket_to_check = s3.buckets[bucket] 
		obj = bucket_to_check.objects[filename]

		begin
			if obj.exists?
				return true
			else
				return false
			end
		rescue Exception => e
				return false
		end
	end
end