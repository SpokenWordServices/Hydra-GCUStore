require 'hydra'

class GenericContent < ActiveFedora::Base
 
  include Hydra::ModelMethods
  include HullModelMethods
  include HullValidationMethods
	
 	#Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :label=>"Rights metadata", :type => Hydra::RightsMetadata 
 
  has_metadata :name => "descMetadata", :label=>"MODS metadata", :control_group=>"M", :type => ModsGenericContent
  
	has_metadata :name => "contentMetadata", :label=>"Content metadata", :control_group=>"M", :type => ContentMetadata

  has_metadata :name => "DC", :label=>"DC admin metadata", :type => ObjectDc

  has_datastream :name=>"content", :label=>"content", :type=>ActiveFedora::Datastream, :mimeType=>"application/pdf", :controlGroup=>'M'

  delegate :title, :to=>:descMetadata 
  delegate :coordinates, :to=>:descMetadata
  delegate :topic_tag, :to=>:descMetadata
  delegate :geographic_tag, :to=>:descMetadata
  delegate :temporal_tag, :to=>:descMetadata
  delegate :rights, :to=>:descMetadata
  delegate :date_valid, :to=>:descMetadata
  delegate :description, :to=>:descMetadata
  delegate :related_item, :to=>:descMetadata
  delegate :extent, :to=>:descMetadata
  delegate :see_also, :to=>:descMetadata
  delegate :publisher, :to=>:descMetadata
  delegate :lang_text, :to=>:descMetadata
  delegate :lang_code, :to=>:descMetadata
  delegate :digital_origin, :to=>:descMetadata
  delegate :type_of_resource, :to=>:descMetadata

  has_validation :validate_parameters do
    if @pending_attributes.fetch("descMetadata",nil)
			date_valid = @pending_attributes["descMetadata"][[:date_valid]]["0"] 
      if date_valid.present?
        begin
          Hull::Iso8601.parse(date_valid) 
        rescue ArgumentError
    			errors << "descMetadata error: invalid date"
        end
      end
		end		
    is_valid?
  end


  def genre=(val)
    g = Genre.find(val)
    descMetadata.genre = g.name
    descMetadata.type_of_resource = g.type
    add_relationship :has_model, "info:fedora/#{g.c_model}"
  end
end
