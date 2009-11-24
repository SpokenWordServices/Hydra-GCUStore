namespace :shelver do
  
  desc 'Index a fedora object of the given pid.'
  task :shelve_object do 
    if ENV['PID']
      puts "indexing #{ENV['PID'].inspect}"
      shelver = Shelver::Shelver.new
      shelver.shelve_object()
      puts "Finished shelving #{ENV[PID]}"
    else
      puts "You must provide a pid using the format 'shelver::shelve_object PID=sample:pid'."
    end
  end
  
  desc 'Index all objects in the repository.'
  task :shelve_objects => :environment do
    shelver = Shelver::Shelver.new
    shelver.shelve_objects
  end
  
end