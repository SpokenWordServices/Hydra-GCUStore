
namespace :hydra do
  namespace :jetty do
    

    desc "Copies the libraries necessary for full-text indexing with solr"
    task :config_full_text do
      rm_r('jetty/solr/contrib') if File.exist?('jetty/solr/contrib')
      cp_r('solr_conf/full_text_support/contrib','jetty/solr')
      ['development-core', 'test-core'].each do |p|
        libdir = "jetty/solr/#{p}/lib"
        mkdir(libdir) unless File.exist?(libdir)
        rm("#{libdir}/apache-solr-cell-nightly.jar") if File.exist?("#{libdir}/apache-solr-cell-nightly.jar")
        FileList.new("solr_conf/full_text_support/dist/*.jar").each do |file|
          cp("#{file}", "#{libdir}/", :verbose => true)
        end
      end
    end

    desc "Copies the default SOLR config files and starts up the fedora instance."
    task :load_with_full_text => ['hydra:jetty:config:all', :start]

    desc "Set up all configs & libraries to run hull"
    namespace :config do
      task :all => ['hydra:jetty:config', 'hydra:jetty:config_fedora', 'hydra:jetty:config_full_text']
    end

  end
end
