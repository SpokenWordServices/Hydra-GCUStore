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
    m.field 'depositor', :string
  end
  
  
  #
  # Adds metadata about the depositor to the asset 
  #
  def apply_depositor_metadata(depositor_id)
    prop_ds = self.datastreams_in_memory["properties"]
    rights_ds = self.datastreams_in_memory["rightsMetadata"]
    
    prop_ds.depositor_values = depositor_id
    rights_ds.update_indexed_attributes([:edit_access, :person]=>depositor_id)
    rights_ds.update_indexed_attributes([:read_access, :person]=>depositor_id)
    rights_ds.update_indexed_attributes([:discover_access, :person]=>depositor_id)
    return true
  end
  
  def insert_contributor(type, opts={})
    ds = self.datastreams_in_memory["descMetadata"]   
    node, index = ds.insert_contributor(type,opts)
    return node, index
  end
  
end
