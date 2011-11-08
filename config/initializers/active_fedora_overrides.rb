

# The following code represents hull-specific overrides to ActiveFedora.  In some cases,
# the overrides can be propogated up to ActiveFedora itself
module ActiveFedora

  class Base

    self.ds_specs = {'RELS-EXT'=> {:type=> ActiveFedora::RelsExtDatastream, :label=>"", :block=>nil}}
    #This method is used to specify the details of a datastream. 
    #args must include :name. Note that this method doesn't actually
    #execute the block, but stores it at the class level, to be executed
    #by any future instantiations.
    # Overriding to change @ds_specs[ds_name] from being stored in two element array to a hash to facilitate providing more options
    def self.has_metadata(args, &block)
      ds_specs[args[:name]]= {:type => args[:type], :label =>  args.fetch(:label,""), :control_group => args.fetch(:control_group,"X"), :disseminator => args.fetch(:disseminator,""), :url => args.fetch(:url,""),:block => block}
    end

    private
    

    def configure_defined_datastreams
      if self.class.ds_specs
        self.class.ds_specs.each do |name,ds_config|
          if self.datastreams.has_key?(name)
            #attributes = self.datastreams[name].attributes
          else
            ds = ds_config[:type].new(inner_object, name)
            ds.model = self if ds_config[:type] == RelsExtDatastream
            ds.dsLabel = ds_config[:label] if ds_config[:label].present?
            ds.controlGroup = ds_config[:control_group]
            # If you called has_metadata with a block, pass the block into the Datastream class
            if ds_config[:block].class == Proc
              ds_config[:block].call(ds)
            end
            additional_attributes_for_external_and_redirect_control_groups(ds, ds_config)
            self.add_datastream(ds)
          end
        end
      end
    end


    # This method provides validation of proper options for control_group 'E' and 'R' and builds an attribute hash to be merged back into ds.attributes prior to saving
    #
    # @param [Object] ds The datastream
    # @param [Object] ds_config hash of options which may contain :disseminator and :url
    def additional_attributes_for_external_and_redirect_control_groups(ds,ds_config)
      if ds.controlGroup=='E'
        raise "Must supply either :disseminator or :url if you specify :control_group => 'E'" if (ds_config[:disseminator].empty? && ds_config[:url].empty?)
        if !ds_config[:disseminator].empty?
          ds.dsLocation= "#{RubydoraConnection.instance.options[:url]}/objects/#{pid}/methods/#{ds_config[:disseminator]}"
        elsif !ds_config[:url].empty?
          ds.dsLocation= ds_config[:url]
        end
      elsif ds.controlGroup=='R'
        raise "Must supply a :url if you specify :control_group => 'R'" if (ds_config[:url].empty?)
        ds.dsLocation= ds_config[:url]
      end
    end
  end

  ## ContentModel must get defined after base or it won't have the correct ds_specs
  class ContentModel < Base  
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
      return "info:fedora/#{namespace}:#{sanitized_class_name}#{pid_suffix}" 
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
end
