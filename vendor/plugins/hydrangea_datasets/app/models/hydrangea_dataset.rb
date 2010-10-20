require "hydra"

class HydrangeaDataset < ActiveFedora::Base
  
  include Hydra::ModelMethods
  
  has_relationship "parts", :is_part_of, :inbound => true
  
  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 
  
  # Uses the Hydra MODS Article profile for tracking most of the descriptive metadata
  has_metadata :name => "descMetadata", :type => Hydra::ModsDataset

  # A place to put extra metadata values
  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'collection', :string
    m.field 'depositor', :string
  end
  
  # A place to put extra extra metadata values
  has_metadata :name => "hydraDataset", :type => HydraDatasetDs
  
  # Call insert_contributor on the descMetadata datastream
  def insert_grant
    ds = self.datastreams_in_memory["hydraDataset"]   
    node, index = ds.insert_grant
    return node, index
  end
  
end
