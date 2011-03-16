require "hydra"

class UketdObject < ActiveFedora::Base
  
  include Hydra::ModelMethods
  
  has_relationship "parts", :is_part_of, :inbound => true
  
  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 
  
  # Uses the Hydra MODS Article profile for tracking most of the descriptive metadata
# TODO: define terminology for ETD
  has_metadata :name => "descMetadata", :type => HullModsEtd

  # A place to put extra metadata values
  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'collection', :string
    m.field 'depositor', :string
  end

  def to_solr(solr_doc=Hash.new, opts={})
    super(solr_doc,opts)
    solr_doc << { "has_model_s" => "UketdObject" }
    solr_doc
  end

end
