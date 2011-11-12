# The following code represents hull-specific overrides to ActiveFedora. 
module ActiveFedora
  class ContentModel < Base  

    ### Serialize class names with first letter downcased
    def self.sanitized_class_name(klass)
      class_name = klass.name.gsub(/(::)/, '_')
      class_name[0,1].downcase + class_name[1..-1]
    end

    def self.default_model(obj)
      unless obj.datastreams['descMetadata'].nil? || obj.datastreams['rightsMetadata'].nil? || obj.datastreams['contentMetadata'].nil?
        if class_exists?("GenericContent")
          m = Kernel.const_get("GenericContent")
          if m
            return m
          end
        end
      end
      ActiveFedora::Base
    end
  end
end