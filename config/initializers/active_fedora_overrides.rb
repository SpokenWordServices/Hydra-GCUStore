

# The following code represents hull-specific overrides to ActiveFedora.  In some cases,
# the overrides can be propogated up to ActiveFedora itself
module ActiveFedora
  class ContentModel
    # overriding to provide a pid like "info:fedora/hull-cModel:uketdObject" rather than "info:fedora/hull-cModel:UketdObject"
    # This adds uniformity to the pids and cModel declarations
    def self.pid_from_ruby_class(klass,attrs={})
      class_name = klass.name.gsub(/(::)/, '_')
      sanitized_class_name = class_name[0,1].downcase + class_name[1..-1]
      unless klass.respond_to? :pid_suffix
        pid_suffix = attrs.has_key?(:pid_suffix) ? attrs[:pid_suffix] : CMODEL_PID_SUFFIX
      else
        pid_suffix = klass.pid_suffix
      end
      unless klass.respond_to? :pid_namespace
        namespace = attrs.has_key?(:namespace) ? attrs[:namespace] : CMODEL_NAMESPACE   
      else
        namespace = klass.pid_namespace
      end
      return "#{namespace}:#{sanitized_class_name}#{pid_suffix}" 
    end

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

  class Base
    #This method is used to specify the details of a datastream. 
    #args must include :name. Note that this method doesn't actually
    #execute the block, but stores it at the class level, to be executed
    #by any future instantiations.
    # Overriding to change @ds_specs[ds_name] from being stored in two element array to a hash to facilitate providing more options
    def self.has_metadata(args, &block)
      @ds_specs ||= Hash.new
      @ds_specs[args[:name]]= {:type => args[:type], :label =>  args.fetch(:label,""), :control_group => args.fetch(:control_group,"X"), :disseminator => args.fetch(:disseminator,""), :url => args.fetch(:url,""),:block => block}
    end

    private
    
    # Overriding this to provide handling of :control_groups 'M', 'E', and 'R'
    def configure_defined_datastreams
      if self.class.ds_specs
        self.class.ds_specs.each do |name,ds_config|

          if self.datastreams.has_key?(name)
            attributes = self.datastreams[name].attributes
          else
            attributes = {:dsLabel=>ds_config[:label]}
            attributes.merge!({:controlGroup=>ds_config[:control_group]})
          end

          # this assumes you have passed in a ds type... for our purposes we 
          ds = ds_config[:type].new(:dsid=>name)

          # If you called has_metadata with a block, pass the block into the Datastream class
          if ds_config[:block].class == Proc
            ds_config[:block].call(ds)
          end

          attributes.merge! additional_attributes_for_external_and_redirect_control_groups(attributes[:controlGroup],ds_config)

          ds.attributes = attributes.merge(ds.attributes)
          self.add_datastream(ds)
        end
      end
    end

    # This method provides validation of proper options for control_group 'E' and 'R' and builds an attribute hash to be merged back into ds.attributes prior to saving
    #
    # @param [String] control_group The single letter designation of the control group: valid values = 'X', 'M', 'E', and 'R'
    # @return [Hash] The attributes to be added for E or R control group, or an empty hash
    def additional_attributes_for_external_and_redirect_control_groups(control_group,ds_config)
      if control_group=='E'
        raise "Must supply either :disseminator or :url if you specify :control_group => 'E'" if (ds_config[:disseminator].empty? && ds_config[:url].empty?)
        if !ds_config[:disseminator].empty?
          return {:dsLocation=>"#{Fedora::Repository.instance.base_url}/objects/#{pid}/methods/#{ds_config[:disseminator]}"}
        elsif !ds_config[:url].empty?
          return {:dsLocation=>ds_config[:url]}
        end
      elsif control_group=='R'
        raise "Must supply a :url if you specify :control_group => 'R'" if (ds_config[:url].empty?)
        return {:dsLocation=>ds_config[:url]}
      end
      {}
    end
  end
end
