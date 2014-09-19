require 'aws-sdk'

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