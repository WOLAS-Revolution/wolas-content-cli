require './thumbnails.rb'
require './content_integrity.rb'
require './Assessment_consistency.rb'

require 'yaml'
require 'active_record'
require 'mysql2'

# e = Thumbnail.new
# e.setup
# e.find

# e = ContentIntegrity.new
# e.set_scope

e = AssessmentConsistency.new
e.commence

