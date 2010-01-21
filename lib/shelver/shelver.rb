require 'lib/shelver/indexer.rb'
require "ruby-debug"

module Shelver
class Shelver

  attr_accessor :indexer

  #
  # This method initializes the indexer
  #
  def initialize()
    @indexer = Indexer.new
  end

  #
  # This method shelves the given Fedora object's full-text and facets into the search index
  #
  def shelve_object( obj )
    # retrieve the Fedora object based on the given unique id
    obj = obj.kind_of?(ActiveFedora::Base) ? obj : Repository.get_object( obj )
    p "Indexing object #{obj.pid} with label #{obj.label}"
    # add the keywords and facets to the search index
    indexer.index( obj )
    p "Successfully indexed object #{obj.pid}."
  end
  
  #
  # This method retrieves a comprehensive list of all the unique identifiers in Fedora and 
  # shelves each object's full-text and facets into the search index
  #
  def shelve_objects
    # retrieve a list of all the pids in the fedora repository
    num_docs = 1000000   # modify this number to guarantee that all the objects are retrieved from the repository
    pids = Repository.get_pids( num_docs )
    puts "Shelving #{pids.length} Fedora objects"
    puts "WARNING: You have turned off indexing of Full Text content.  Be sure to re-run indexer with INDEX_FULL_TEXT set to true in main.rb" if INDEX_FULL_TEXT == false
    pids.each do |pid|
      shelve_object( pid )
    end
  end

end
end
