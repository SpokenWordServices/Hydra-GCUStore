require 'fastercsv'

module Shelver
  class Replicator
    
    include Stanford::SaltControllerHelper
    attr_accessor :dest_repo, :configs
    
    def initialize
      config_path = "#{RAILS_ROOT}/config/replicator.yml"
      raw_configs = YAML::load(File.open(config_path))
      @configs = raw_configs[RAILS_ENV]
      @dest_repo = Fedora::Repository.new(configs["destination"]["fedora"]["url"])
      
      ActiveFedora.fedora_config[:url] = configs["source"]["fedora"]["url"]
      logger.info("REPLICATOR: re-initializing Fedora with fedora_config: #{ActiveFedora.fedora_config.inspect}")
 
      Fedora::Repository.register(ActiveFedora.fedora_config[:url])
      logger.info("REPLICATOR: re-initialized Fedora as: #{Fedora::Repository.instance.inspect}")
      
      # Register Solr
      ActiveFedora.solr_config[:url] = configs["source"]["solr"]["url"]
      
      logger.info("REPLICATOR: re-initializing ActiveFedora::SolrService with solr_config: #{ActiveFedora.solr_config.inspect}")
 
      ActiveFedora::SolrService.register(ActiveFedora.solr_config[:url])
      
    end
    
    def replicate_objects
      puts "Replicating objects from #{Fedora::Repository.instance.fedora_url} to #{@dest_repo.fedora_url}"
      
      # retrieve a list of all the pids in the fedora repository
      num_docs = 1000000   # modify this number to guarantee that all the objects are retrieved from the repository
      #pids = Repository.get_pids( num_docs )
      #puts "Replicating #{pids.length} Fedora objects"
      #pids.reverse!
      #pids.each do |pid|
      #  replicate_object( pid )
      #end
      
       file = '/tmp/todo.csv'
        FasterCSV::foreach(file, :headers=>true) do |row|
           pid = row[0].chomp
            replicate_object( pid )
        end


      #puts "Finished replicating all #{pids.length} objects."
    end   

 
    def replicate_object(pid)
	#source_doc = Document.load_instance(pid)
        source_doc = ActiveFedora::Base.load_instance(pid)
	  p "Indexing object #{source_doc.pid} with label #{source_doc.label}"
      begin
        unless source_doc.nil?
		create_stub(source_doc)
        	p "Successfully replicated #{source_doc.pid}"
   	end 
     rescue Exception => e
        p "unable to create stub.  Failed with #{e.inspect}"
      end
    end
    
    # Creates a stub object in @dest_repo with the datastreams that we need in the stubs
    def create_stub(source_object)
      
      begin
        
       jp2 = downloadables(source_object, :canonical=>true, :mime_type=>"image/jp2")   
       jp2.new_object = true
       jp2.control_group = 'M'
       jp2.blob = jp2.content
      
       	stub_object = Fedora::FedoraObject.new(:pid=>source_object.pid)
       	dest_repo.save(stub_object)   
	      dest_repo.save(jp2)
      
      ["properties", "extProperties", "descMetadata", "location"].each do |ds_name|
        ds = source_object.datastreams[ds_name]
        ds.new_object = true
        ds.blob = ds.content
        dest_repo.save(ds)
      end
     
     rescue
         #for object without jp2s
        pid = source_object.pid 
	p "> #{pid}"
        
          jp2_file = File.new('spec/fixtures/image.jp2')
          ds = ActiveFedora::Datastream.new(:dsID => "image.jp2", :dsLabel => 'image.jp2', :controlGroup => 'M', :blob => jp2_file)
	  source_object.add_datastream(ds)
          source_object.save 
	#  source_object = Document.load_instance(pid)
 	  source_object = ActiveFedora::Base.load_instance(pid)
       	  stub_object = Fedora::FedoraObject.new(:pid=>source_object.pid)
          dest_repo.save(stub_object)
         
          jp2 = downloadables(source_object, :canonical=>true, :mime_type=>"image/jp2")   
          jp2.new_object = true
          jp2.control_group = 'M'
          jp2.blob = jp2.content

          	stub_object = Fedora::FedoraObject.new(:pid=>source_object.pid)
          	dest_repo.save(stub_object)   
   	      dest_repo.save(jp2)

         ["properties", "extProperties", "descMetadata", "location"].each do |ds_name|
           ds = source_object.datastreams[ds_name]
           ds.new_object = true
           ds.blob = ds.content
           dest_repo.save(ds)
         end  
    
      end    
    end
    def logger
      @logger ||= defined?(RAILS_DEFAULT_LOGGER) ? RAILS_DEFAULT_LOGGER : Logger.new(STDOUT)
    end
    
  end
end
