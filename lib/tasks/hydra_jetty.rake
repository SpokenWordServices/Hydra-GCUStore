
namespace :hydra do
  namespace :jetty do
    
#     desc "Copies the default SOLR config for the bundled Hydra Testing Server"
#     task :config_solr do
#       ### solr_config from hydra-head should take care of solr_config/conf for us, we'll just do the rest
#       FileList['solr_conf/conf/*'].each do |f|  
# puts "Right here"
#         cp("#{f}", 'jetty/solr/development-core/conf/', :verbose => true)
#         cp("#{f}", 'jetty/solr/test-core/conf/', :verbose => true)
#       end
# 
#     end
# 

    desc "Deploy files for OAI Provider service"
    task :config_oai do
      cp_r("fedora_conf/oai/oaiprovider", "jetty/webapps/", :verbose => true)
    end

    desc "Copies the libraries necessary for full-text indexing with solr"
    task :config_full_text do
#      rm_r('jetty/solr/contrib') if File.exist?('jetty/solr/contrib')
      cp("solr_conf/solr.xml", "jetty/solr/", :verbose => true)
      cp_r("solr_conf/full_text_support/contrib/extraction/lib", "jetty/solr/", :verbose => true)
      FileList.new("solr_conf/full_text_support/dist/*.jar").each do |file|
        cp("#{file}", "jetty/solr/lib/", :verbose => true)
      end
      # ['development-core', 'test-core'].each do |p|
      #   libdir = "jetty/solr/#{p}/lib"
      #   mkdir(libdir) unless File.exist?(libdir)
      #   rm("#{libdir}/apache-solr-cell-nightly.jar") if File.exist?("#{libdir}/apache-solr-cell-nightly.jar")
      #   FileList.new("solr_conf/full_text_support/dist/*.jar").each do |file|
      #     cp("#{file}", "#{libdir}/", :verbose => true)
      #   end
      # end
    end

    desc "Copies the default SOLR config files and starts up the fedora instance."
    task :load_with_full_text => ['hydra:jetty:config:all', :start]

    desc "Set up all configs & libraries to run hull"
    namespace :config do
      task :all => ['hydra:jetty:config', 'hydra:jetty:config_full_text']
    end

  end
end
