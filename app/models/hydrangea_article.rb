require "hydra"
require "nokogiri"
class HydrangeaArticle < ActiveFedora::Base
  
  has_relationship "parts", :is_part_of, :inbound => true
  
  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 
  
  # Uses the Hydra MODS Article profile for tracking most of the descriptive metadata
  has_metadata :name => "descMetadata", :type => Hydra::ModsArticle 

  # A place to put extra metadata values
  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'collection', :string
  end
  
  def insert_contributor(type, opts={})
    ds = self.datastreams_in_memory["descMetadata"]   
    node, index = ds.insert_contributor(type,opts)
    return node, index
  end
  
end
