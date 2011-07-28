ActiveFedora::ContentModel.class_eval do
	def self.known_models_for(obj)
		  models_array = []
      models_asserted_by( obj ).each do |model_uri|
				m = uri_to_model_class(model_uri)
        if m
          models_array << m
        end
      end

	    if models_array.empty?
				fall_back_to_base = true
				unless obj.datastreams_in_memory["descMetadata"].nil? || obj.datastreams_in_memory["rightsMetadata"].nil? || obj.datastreams_in_memory["contentMetadata"].nil?
					if class_exists?("GenericContent")
        		m = Kernel.const_get("GenericContent")
						if m
							models_array << m
							fall_back_to_base = false
						end
					end
				end
				if fall_back_to_base
					models_array = [ActiveFedora::Base]
				end				
      end
      
      return models_array

    end
end
