module HullValidationMethods
    
    def errors
      @errors ||= []
    end

    private 
    
    def validate(&validation_block)
      errors.clear
      begin
        yield validation_block
      rescue HullValidationMethods::ValidationError
        return false
      end
      self.errors.empty?
    end

    def validates_presence_of(*attr_names)
      configuration = {:message=>"is missing"}
      configuration.update(attr_names.extract_options!)
      
      datastream_name, fields = attr_names

      values = self.datastreams[datastream_name].get_values(fields)
      
      return true if !values.empty? && !values.first.empty?
      self.errors << construct_message(datastream_name,fields,configuration[:message])
      false
    end

    def validates_format_of(*attr_names)
      configuration = {:on => :publish,:message=>"has invalid format"}
      configuration.update(attr_names.extract_options!)
      
      format_errors = []
      
      datastream_name, fields = attr_names

      raise(ArgumentError, "A regular expression must be supplied as the :with option of the configuration hash") unless configuration[:with].is_a?(Regexp)

      values = self.datastreams[datastream_name].get_values(fields)
      if !values.empty? && !values.first.empty?
        values.each_with_index do |val,index|
          match = val.match(configuration[:with])
          next if match
          format_errors << construct_message(datastream_name,fields,configuration[:message])
        end
      end
      format_errors.each {|e| self.errors << e }

      format_errors.empty?

    end

    def validates_queue_membership(*attr_names)
      configuration = {:message=>"is not properly queued"}
      configuration.update(attr_names.extract_options!)
      
      
    end

    def validates_queue_membership_exclusive(*attr_name)
    end

    def construct_message(datastream_name,fields,message)
      "#{datastream_name}[#{fields.join("_")}] #{message}"
    end

    class ValidationError < RuntimeError; end # :nodoc:

    
end


