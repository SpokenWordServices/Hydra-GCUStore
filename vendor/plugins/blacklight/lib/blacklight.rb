module Blacklight
  
  autoload :CoreExt, 'blacklight/core_ext.rb'
  # load up the CoreExt by referencing it:
  CoreExt
  
  autoload :Configurable, 'blacklight/configurable'
  autoload :Solr, 'blacklight/solr.rb'
  autoload :Marc, 'blacklight/marc.rb'
  
  autoload :SolrHelper, 'blacklight/solr_helper'
  
  extend Configurable
  
  class << self
    attr_accessor :solr, :solr_config
  end
  
  # The configuration hash that gets used by RSolr.connect
  @solr_config ||= {}
  
  def self.solr(index=:default)
    @solr[index]
  end
  
  def self.init
    
    solr_config = YAML::load(File.open("#{RAILS_ROOT}/config/solr.yml"))
    raise "The #{RAILS_ENV} environment settings were not found in the solr.yml config" unless solr_config[RAILS_ENV]
    
    Blacklight.solr_config = solr_config[RAILS_ENV]
    # Create a global connection instance
    Blacklight.solr = Blacklight.solr_config.inject(HashWithIndifferentAccess.new) do |hash, index|
      key, value = *index
      hash[key] = RSolr::Ext.connect(value.to_options)
      if Gem.available?('curb')
        require 'curb'
        hash[key].adapter.connector.adapter_name = :curb
      else
        hash[key].adapter.connector.adapter_name = :net_http
      end
      hash
    end
    
    # set the SolrDocument.connection to Blacklight.solr
    SolrDocument.connection = Blacklight.solr
    
    logger.info("BLACKLIGHT: initialized with Blacklight.solr_config: #{Blacklight.solr_config.inspect}")
    logger.info("BLACKLIGHT: initialized with Blacklight.solr: #{Blacklight.solr.inspect}")
    logger.info("BLACKLIGHT: initialized with Blacklight.config: #{Blacklight.config.inspect}")
    
  end

  def self.logger
    RAILS_DEFAULT_LOGGER
  end
  
end