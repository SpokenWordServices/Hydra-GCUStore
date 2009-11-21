require 'active-fedora'
#
# Misc Config for SALT Application
#


# This initializes ActiveFedora with config info from RAOLS_ROOT/lib/fedora.yml
# Among other things, it allows you to access Fedora and Solr (ActiveFedora's copy) as ActiveFedora.fedora and ActiveFedora.solr
ENABLE_SOLR_UPDATES=false
ActiveFedora.init

#
# Loads EAD descriptors 
# Attempts to parse any xml files in lib/stanford/ead/
#
# You can access any of the loaded descriptors using Descriptor.retrieve( id ), where "id" is the base filename of the descriptor xml file

# puts "Registering EADs..."
# Dir[File.join( RAILS_ROOT, 'lib', "stanford", "ead", "/*.xml" )].each do |f| 
#   puts "... EAD id #{File.basename(f, ".xml")}"
#   Descriptor.register( File.basename(f, ".xml") ) 
# end

