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
  has_metadata :name => "HydraDataset", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'completeness', :string
    m.field 'interval', :string
    m.field 'data_type', :string
    m.field 'timespan_start', :string
    m.field 'timespan_end', :string
    m.field 'gps', :string
    m.field 'region', :string    
    m.field 'site', :string    
    m.field 'ecosystem', :string  
    m.field 'grants' do |g|    
      g.field 'grant_organization', :string
      g.field 'grant_number', :string
    end
    m.field 'data_quality', :string
    m.field 'contact_name', :string
    m.field 'contact_email', :string
  end

  
end
