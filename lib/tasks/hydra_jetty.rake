
namespace :hydra do
  namespace :jetty do
    

    desc "Copies the libraries necessary for full-text indexing with solr"
    task :config_full_text do
      rm_r('jetty/solr/contrib') if File.exist?('jetty/solr/contrib')
      cp_r('solr/full_text_support/contrib','jetty/solr')
      f = 'solr/full_text_support/dist/apache-solr-cell-1.4.1.jar'
      cp("#{f}", 'jetty/solr/development-core/lib/', :verbose => true)
    end

    desc "Copies the default SOLR config files and starts up the fedora instance."
    task :load_with_full_text => [:config, :config_fedora, :config_full_text, :start]

  end
end
