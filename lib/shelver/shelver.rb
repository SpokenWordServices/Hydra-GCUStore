
require 'lib/shelver/indexer.rb'
require 'fastercsv'
require "ruby-debug"



module Shelver
class Shelver

  attr_accessor :indexer

  #
  # This method initializes the indexer
  #
  def initialize()
    @@index_list = false unless defined?(@@index_list)
    @@index_full_text = ""
    @indexer = Indexer.new
  end

  #
  # This method shelves the given Fedora object's full-text and facets into the search index
  #
  def shelve_object( obj )
    # retrieve the Fedora object based on the given unique id
      
      start = Time.now
      p "Retrieving object #{obj} ."
      obj = obj.kind_of?(ActiveFedora::Base) ? obj : Repository.get_object( obj )
        
          obj_done = Time.now
          obj_done_elapse = obj_done - start
          p "Object retrival completed. Duration: #{obj_done_elapse}"
          
          unless obj.datastreams['descMetadata'].nil? || obj.datastreams['location'].nil?
                 p "Indexing object #{obj.pid} . "
                 # add the keywords and facets to the search index
                 index_start = Time.now
                 indexer.index( obj )
                 
                 index_done = Time.now
                 index_elapsed = index_done - index_start
                 
                  p "Successfully indexed object #{obj.pid} . Duration:  #{index_elapsed} ."s
          end
      rescue
        
  
  end
  
  #
  # This method retrieves a comprehensive list of all the unique identifiers in Fedora and 
  # shelves each object's full-text and facets into the search index
  #
  def shelve_objects
    # retrieve a list of all the pids in the fedora repository
    num_docs = 1000000   # modify this number to guarantee that all the objects are retrieved from the repository
    puts "WARNING: You have turned off indexing of Full Text content.  Be sure to re-run indexer with @@index_full_text set to true in main.rb" if @@index_full_text == false

    if @@index_list == false
     
       pids = Repository.get_pids( num_docs )
	     puts "Shelving #{pids.length} Fedora objects"
       pids.each do |pid|
         unless pid[0].empty? || pid[0].nil?
          shelve_object( pid )
          end
        end #pids.each
     
    else
    
       if File.exists?(@@index_list)
          arr_of_pids = FasterCSV.read(@@index_list, :headers=>false)
          
          puts "Indexing from list at #{@@index_list}"
          puts "Shelving #{arr_of_pids.length} Fedora objects"
          
         arr_of_pids.each do |row|
            pid = row[0]
            shelve_object( pid )
          end #FASTERCSV
        else
          puts "#{@@index_list} does not exists!"
        end #if File.exists
     
    end #if Index_LISTS
  end #shelve_objects

end #class
end #module
