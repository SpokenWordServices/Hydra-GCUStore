require 'hydra'

class GenericContent < ActiveFedora::Base
 
  include Hydra::ModelMethods
  include HullModelMethods
  include HullValidationMethods
	
 	#Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 
 
  has_metadata :name => "descMetadata", :type => ModsGenericContent
  
	has_metadata :name => "contentMetadata", :type => ContentMetadata

  has_metadata :name => "DC", :type => ObjectDc

  has_datastream :name=>"content", :type=>ActiveFedora::Datastream, :mimeType=>"application/pdf", :controlGroup=>'M'

end
