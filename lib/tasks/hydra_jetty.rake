# if you would like to see solr startup messages on STDERR
# when starting solr test server during functional tests use:
# 
#    rake SOLR_CONSOLE=true
require File.expand_path(File.dirname(__FILE__) + '/../hydra/hydra_testing_server.rb')


JETTY_PARAMS = {
  :quiet => ENV['HYDRA_CONSOLE'] ? false : true,
  :jetty_home => ENV['HYDRA_JETTY_HOME'],
  :jetty_port => ENV['HYDRA_JETTY_PORT'],
  :solr_home => ENV['HYDRA_SOLR_HOME'],
  :fedora_home => ENV['HYDRA_SOLR_HOME']
}

namespace :hydra do
namespace :jetty do
  desc "Starts the bundled Hydra Testing Server"
  task :start do
    HydraTestingServer.configure(JETTY_PARAMS)
    HydraTestingServer.instance.start
  end
  
  desc "Stops the bundled Hydra Testing Server"
  task :stop do
    puts "stopping #{HydraTestingServer.instance.pid}"
    HydraTestingServer.instance.stop
  end
end
end