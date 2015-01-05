# require gems & libraries.
require 'yaml' #gem install yaml
require 'active_record' #gem install active_record
require 'mysql2' #gem install yaml

# require active record models.
require './models/address.rb'
require './models/assessor.rb'
require './models/avetmiss.rb'
require './models/business.rb'
require './models/contact.rb'
require './models/enrol.rb'
require './models/life_activity.rb'
require './models/lifedates.rb'
require './models/lifedetails.rb'
require './models/record.rb'
require './models/staff.rb'
require './models/student.rb'
require './models/supervisor.rb'
require './models/supervisor_life.rb'
require './models/tpar.rb'
require './models/user.rb'
require './models/online_userid.rb'

DB_CONFIG = YAML::load(File.open('./config/database.yml'))
#ActiveRecord::Base.establish_connection("mysql2://#{DB_CONFIG['username']}:#{DB_CONFIG['password']}@#{DB_CONFIG['host']}:#{DB_CONFIG['port']}/#{DB_CONFIG['database']}")	
ActiveRecord::Base.establish_connection("mysql2://root:Password1@192.168.1.91:3306/customer")
ActiveRecord::Base.establish_connection("mysql2://root:Password1@192.168.1.91:3306/customerExtended")
ActiveRecord::Base.establish_connection("mysql2://root:Password1@192.168.1.91:3306/client")
ActiveRecord::Base.establish_connection("mysql2://root:a97m2o4h3lck@127.0.0.1:3306/tpar")
ActiveRecord::Base.establish_connection("mysql2://root:a97m2o4h3lck@127.0.0.1:3306/auth")
ActiveRecord::Base.establish_connection("mysql2://root:Password1@192.168.1.91:3306/assessment")

first_names = ['corey', 'jacob', 'martin']
last_names = ['stinson', 'webber', 'brennan']
street_names = ['abbots', 'mayweather', 'balthazar']
rand_domains = ['iinet', 'webmail', 'hotmail', 'gmail']
states = ['QLD', 'NSW', 'TAS', 'VIC', 'NT', 'WA', 'ACT']

assessor_first_name = first_names[rand(first_names.length)]
assessor_last_name = last_names[rand(last_names.length)]
assessor_domain = rand_domains[rand(rand_domains.length)]

# creates a new contact record with a randomised 8 digit landline/fax, 2 digit area code
# and a 10 digit mobile number. uses the first_names and rand_domains array to create an
# email address. Returns contact_id
def create_contact(first_names, rand_domains)
	puts "creating a new contact record"

	landline = ""
	fax = ""
	8.times do
		landline += rand(10).to_s
		fax += rand(10).to_s
	end

	mobile = ""
	10.times do
		mobile += rand(10).to_s
	end

	area = ""
	2.times do
		area += rand(10).to_s
	end

	email = "#{first_names[rand(first_names.length)]}@#{rand_domains[rand(rand_domains.length)]}.com"

	contact = Contact.create(
		landline: landline, 
		fax: fax, 
		mobile: mobile, 
		area: area, 
		email: email
		)

	puts "contact record created. id: #{contact.id}"
	contact.id
end

# creates a new address record with a randomised 3 digit street_number and random
# street name from the street_names array. state is randomised from the state array
# and suburbID is hard-coded to id 1. Returns address_id
def create_address(street_names, states)
	puts "creating a new address record"

	street_number = ""
	3.times do
		street_number += rand(10).to_s
	end

	street_name = street_names[rand(street_names.length)]

	state = states[rand(states.length)]

	address = Address.create(
		streetNumber: street_number,
		streetName: street_name,
		suburbID: 1, 
		state: state
		)

	puts "address record created. id: #{address.id}"
	address.id
end

# creates a new auth record with a randomised first_name and last_name from the arrays.
# randomises an email address from the first_name and domain arrays.
# sets the dob field to the current datetime in utc, and the password / passwordsalt
# to PASSWORD and PASSWORDSALT values that will be required to be overriden. Returns userID
def create_auth(first_names, last_names, rand_domains)

	users = User.all

	emails = users.map do |user|
		user.email
	end

	email = "#{first_names[rand(first_names.length)]}@#{rand_domains[rand(rand_domains.length)]}.com"

	# ensure the email generated does not already exist.
	if emails.include? email

		# fire the method again for another email generation
		create_auth(first_names, last_names, rand_domains)

	else

		puts "creating a new auth record"
		new_guid = SecureRandom.uuid

		User.create(
			id: new_guid,
			first_name: first_names[rand(first_names.length)],
			last_name: last_names[rand(last_names.length)],
			email: email,
			dob: DateTime.now.utc,
			password: 'PASSWORD',
			password_salt: 'PASSWORDSALT',
			failed_logins: 0,
			active: 1,
			locked: 0
			)

		puts "auth record created. id: #{new_guid}"
		new_guid
	end
end

# creates a new online_userid record with the guid passed. Returns ID
def create_online_userid(guid)
	puts "created a new online_userid record"

	model = OnlineUserID.create(userID: guid)

	puts "online_userid record created. id: #{model.id}"
	model.id
end

# number of entries is limited to the number of distinct emails the program can
# generate, divided by three as each iteration will create for assessor / student / supervisor.
limit = first_names.length * rand_domains.length

puts "SEED COMMENCING. Limited to #{limit / 3} entries"

limit / 3.times do |index|
	puts "commencing entry #{index + 1}"

	# --- assessor ---
	puts "commencing assessor creation"

	contact_id = create_contact(first_names, rand_domains)
	# address_id = create_address(street_names, states)
	new_guid = create_auth(first_names, last_names, rand_domains)
	link_id = create_online_userid(new_guid)

	puts "creating a new assessor record."
	Assessor.create(
		firstName: first_names[rand(first_names.length)],
		lastName: last_names[rand(last_names.length)],
		onlineLinkID: link_id,
		contactID: contact_id,
		active: 1
		)
	puts "assessor creation completed."

	# --- business ---
	puts "commencing business creation"

	
	
	puts "business creation completed"

	puts "ENTRY #{index + 1} / #{limit} COMPLETED."
end























