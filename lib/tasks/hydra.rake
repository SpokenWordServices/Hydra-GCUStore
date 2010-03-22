# require File.expand_path(File.dirname(__FILE__) + '/hydra_jetty.rb')

namespace :hydra do
  
  desc "Export the object identified by pid into spec/fixtures"
  task :harvest_fixture => :environment do
        
    # If a source url has been provided, attampt to export from the fedora repository there.
    if ENV["source"]
      Fedora::Repository.register(ENV["source"])
    end
    
    # If Fedora Repository connection is not already initialized, initialize it using ActiveFedora defaults
    ActiveFedora.init unless Thread.current[:repo]
    
    if ENV["pid"].nil? 
      puts "You must specify a valid pid.  Example: rake hydra:harvest_fixture pid=demo:12"
    else
      pid = ENV["pid"]
      puts "Exporting '#{pid}' from #{Fedora::Repository.instance.fedora_url}"
      foxml = Fedora::Repository.instance.export(pid)
      filename = File.join("spec","fixtures","#{pid.gsub(":","_")}.foxml.xml")
      file = File.new(filename,"w")
      file.syswrite(foxml)
      puts "The object has been saved as #{filename}"
    end
  end
  

end