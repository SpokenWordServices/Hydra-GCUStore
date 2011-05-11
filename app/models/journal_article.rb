require "hydra"

class JournalArticle < ActiveFedora::Base
  
  include Hydra::ModelMethods
  include HullModelMethods

  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 
  
  has_metadata :name => "descMetadata", :type => Hydra::ModsJournalArticle

  has_metadata :name => "contentMetadata", :type => ContentMetadata

  has_metadata :name => "DC", :type => ActiveFedora::NokogiriDatastream

  has_datastream :name=>"content", :type=>ActiveFedora::Datastream, :mimeType=>"application/pdf", :controlGroup=>'M'

  # A place to put extra metadata values
  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'collection', :string
    m.field 'depositor', :string
  end

  def to_solr(solr_doc=Hash.new, opts={})
    super(solr_doc,opts)
    solr_doc << { "has_model_s" => "info:fedora/hull-cModel:journalArticle" }
    solr_doc
  end

end
