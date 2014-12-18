require './thumbnails.rb'
require './content_integrity.rb'
require './Assessment_consistency.rb'

# e = Thumbnail.new
# e.setup
# e.find

# e = ContentIntegrity.new
# e.set_scope

e = AssessmentConsistency.new
e.commence

