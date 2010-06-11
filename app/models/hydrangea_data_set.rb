class HydrangeaDataSet < ActiveFedora::Base
  
  has_relationship "parts", :is_part_of, :inbound => true
  
  has_metadata :name => "rightsMetadata", :type => ActiveFedora::MetadataDatastream do |m|
    m.field "discover_access_group", :string
    m.field "read_access_group", :string
    m.field "edit_access_group", :string
    
    m.field "discover_access", :string
    m.field "read_access", :string
    m.field "edit_access", :string
  end
  
  has_metadata :name => "descMetadata", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'title', :string
    m.field 'researcher_first_name', :string
    m.field 'researcher_last_name', :string
    m.field 'research_institution', :string
    m.field 'data_owner', :string
    m.field 'description', :date
    m.field 'topic_tag', :string
    m.field 'dataset_includes', :string
    m.field 'coverage_date_start', :date
    m.field 'coverage_date_end', :date
    m.field 'longitude', :string
    m.field 'latitude', :string
  end
end
