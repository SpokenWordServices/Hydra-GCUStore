module CommonMetadataSdef
	  def self.included(mod)		  
      #mod.has_service_definition "hydra-sDef:commonMetadata"
      #Deliberately calling the (Service_defintion) add_method direct
      #  - This saves a call to fedora to get commonMetadata methods when we know we just want 'getOAI_DC' 
      mod.add_method! "hydra-sDef:commonMetadata", "getOAI_DC"
 	  end
end

