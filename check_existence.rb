require 'aws-sdk'

class CheckExistence
	
	AWS.config(YAML.load_file('./config/aws-s3.yaml'))

	def check (bucket, filename)
			
		s3 = AWS::S3.new
		bucket_to_check = s3.buckets['bucket'] 
		obj = bucket_to_check.objects["#{filename}"]
		
		begin
			if obj.exists?
				return 'true'
			else
				return 'false'
			end
		rescue  
				return 'false'
		end
	end
end