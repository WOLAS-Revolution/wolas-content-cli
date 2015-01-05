# require gems & libraries.
require 'yaml' #gem install yaml
require 'active_record' #gem install active_record
require 'mysql2' #gem install yaml
require 'aws-sdk' #gem install aws-sdk
require 'securerandom' #gem install secure-random

require './models/file.rb'
require './models/life.rb'
require './models/answer.rb'
require './models/submission.rb'
require './models/portfolio.rb'
require './models/portfolio_answer.rb'
require './models/item.rb'

DB_CONFIG = YAML::load(File.open('./config/database.yml'))
ActiveRecord::Base.establish_connection("mysql2://root:Password1@192.168.1.91:3306/client")
ActiveRecord::Base.establish_connection("mysql2://root:Password1@192.168.1.91:3306/assessment")
ActiveRecord::Base.establish_connection("mysql2://root:Password1@192.168.1.91:3306/customer")

AWS.config(YAML.load_file('./config/aws-s3.yml'))

s3 = AWS::S3.new

files = ClientFile.all.limit(5)
puts "#{files.length}"
answer_ids = files.map do |file| file.answerID end.uniq

answers = Answer.where(id: answer_ids)
puts "#{answers.length}"
submission_ids = answers.map do |answer| answer.submissionID end.uniq
item_ids = answers.map do |answer| answer.itemID end.uniq

submissions = Submission.where(id: submission_ids)
puts "#{submissions.length}"
life_ids = submissions.map do |submission| submission.lifeID end.uniq

lives = Life.where(id: life_ids)
puts "#{lives.length}"

items = Item.where(id: item_ids)
puts "#{items.length}"

OLD_BUCKET = s3.buckets["wolasuploads"]
NEW_BUCKET = s3.buckets["t1uploads"]

puts 'Commencing ...'
count = 1
files.each do |file|

	answer = answers.select{ |a| a.id == file.answerID }[0]
	submission = submissions.select{ |a| a.id == answer.submissionID }[0]
	item = items.select{ |i| i.id == answer.itemID }[0]
	life = lives.select{ |i| i.id == submission.lifeID}[0]

	file_split = file.bucketKey.split('/')
	file_name = file_split[file_split.length - 1]

	old_bucket_key = "#{file.bucketKey}"
	random = SecureRandom.hex(8)
	new_split = file_name.split('.')
	ext = new_split[new_split.length - 1]
	new_bucket_key = "portfolio/#{life.studentID}/#{random}.#{ext}"
	puts OLD_BUCKET.inspect
	puts old_bucket_key

	old_object = OLD_BUCKET.objects[old_bucket_key]
	new_object = NEW_BUCKET.objects[new_bucket_key]

	old_object.copy_to(new_object)

	portfolio = Portfolio.create(student_id: life.studentID, title: item.title,
				caption: "Uploaded as evidence in support of competency for question: #{item.title}",
				type: "Unknown", protected: true, thumbnail: "default.png", created: submission.date,
				public: false, bucket_key: new_bucket_key)

	PortfolioAnswer.create(answer_id: answer.id, portfolio_id: portfolio.id)


	puts "DONE #{count}/#{files.length}"
	count = count + 1
end
puts 'Finished'