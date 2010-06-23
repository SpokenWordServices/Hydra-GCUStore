require "hydra"

class ModsArticle < ActiveFedora::Base
  
  has_relationship "parts", :is_part_of, :inbound => true
  
  # simpleRightsMetadata datastream is a stand-in for the rightsMetadata datastream that will eventually have Hydra Rights Metadata xml in it
  # It will eventually be declared with this one-liner:
  # has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadataDatastream
  
  has_metadata :name => "rightsMetadata", :type => ActiveFedora::MetadataDatastream do |m|
    m.field "discover_access_group", :string
    m.field "read_access_group", :string
    m.field "edit_access_group", :string
    
    m.field "discover_access", :string
    m.field "read_access", :string
    m.field "edit_access", :string
  end
  
  # modsMetadata datastream is a stand-in for the descMetadata datastream that will eventually have MODS metadata in it
  # It will eventually be declared with this one-liner:
  # has_metadata :name => "descMetadata", :type => Hydra::ModsDatastream 
  
  has_metadata :name => "descMetadata", :type => Hydra::ModsArticle 

  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'collection', :string
  end
end
