require 'hydra'

class GenericContent < ActiveFedora::Base
 
  include Hydra::ModelMethods
  include HullModelMethods
  include HullValidationMethods
	
 	#Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :label=>"Rights metadata", :type => Hydra::RightsMetadata 
 
  has_metadata :name => "descMetadata", :label=>"MODS metadata", :type => ModsGenericContent
  
	has_metadata :name => "contentMetadata", :label=>"Content metadata", :type => ContentMetadata

  has_metadata :name => "DC", :label=>"DC admin metadata", :type => ObjectDc

  has_datastream :name=>"content", :label=>"content", :type=>ActiveFedora::Datastream, :mimeType=>"application/pdf", :controlGroup=>'M'

  has_validation :validate_parameters do
    if @pending_attributes.fetch("descMetadata",nil)
			date_valid = @pending_attributes["descMetadata"][[:date_valid]]["0"] 
      if date_valid.present?
        begin
          Iso8601.parse(date_valid) 
        rescue ArgumentError
    			errors << "descMetadata error: invalid date"
        end
      end
		end		
    is_valid?
  end
end
