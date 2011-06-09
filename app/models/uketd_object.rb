require "hydra"

class UketdObject < ActiveFedora::Base
  
  include Hydra::ModelMethods
  include HullModelMethods
  include HullValidationMethods

  has_relationship "parts", :is_part_of, :inbound => true
  
  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 
  
  # Uses the Hydra MODS Article profile for tracking most of the descriptive metadata
# TODO: define terminology for ETD
  has_metadata :name => "descMetadata", :type => HullModsEtd

  has_metadata :name => "UKETD_DC", :type => ActiveFedora::NokogiriDatastream

  has_metadata :name => "DC", :type => ActiveFedora::NokogiriDatastream

  has_metadata :name => "contentMetadata", :type => ContentMetadata

  # A place to put extra metadata values
  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'collection', :string
    m.field 'depositor', :string
  end

  def file_objects_append(obj)
    super(obj)
    # add handler for updating contentMetadata datastreams    
  end

  def valid_for_publish_queue?
    validate do
      validates_presence_of("descMetadata",[:title])
      validates_presence_of("descMetadata",[:name,:namePart])
      validates_presence_of("descMetadata",[:subject_topic])
      validates_presence_of("descMetadata",[:language,:lang_code])
      validates_presence_of("descMetadata",[:origin_info,:publisher])
      validates_presence_of("descMetadata",[:qualification_level])
      validates_presence_of("descMetadata",[:qualification_name])
      validates_presence_of("descMetadata",[:physical_description,:extent])

      validates_format_of("descMetadata",[:origin_info,:date_issued],:message=>"is not valid",:with=>/^\d\d\d\d$/)
    end
  end
end
