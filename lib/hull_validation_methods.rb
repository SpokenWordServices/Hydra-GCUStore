#  HullValidationMethods is an attempt to provide some standard validation methods for validating metadata
#
#  Rails validations has served as a model, though the complexity of active fedora objects necessitates
#  a bit more open approach
#
#  Included some standard validators using standard Rails nomenclature: validates_presence_of and validates_format_of
#  
#  The #validate method recieves a block which can call these methods for validation
#  
#  == Custom methods
#
#  Alternatively, methods can be defined in the model and passed to #validate in the code block:
#
#  def some_complex_bit_of_logic
#    that_verifies_validity()
#    errors << "really complex validation did not pass"
#  end
#
#  def valid_for_something?
#    validation do
#      validates_presence_of "descMetadata", [:title], :message=>"must be supplied"
#      some_complex_bit_of_logic
#    end
#  end
# 
#  == Custom procs/blocks
#
#  You are not limited to the standard validators or even custom methods:
#
#  def valid_for_wednesday?
#    validation do
#        errors << "not a Wednesday" unless Time.new.wday == 3
#    end
#  end
#
#  
#    
module HullValidationMethods

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods
      
      def has_validation(validator_name,&validation)
        define_method validator_name, &validation 
      end

      def has_workflow_validation(step_name, &validation)
        has_validation "ready_for_#{step_name}?".to_sym, &validation 
      end

    end


    # Provides a method for accessing validation errors
    #
    # @return [Array] An array of string messages indicating validation failures
    def errors
      @errors ||= []
    end

    protected 
    
    # A hook method for passing in validations to perform
    #
    # @param [Block] &validation_block A block containing validations to be performed
    def validation(&validation_block)
      raise HullValidationMethods::NoValidationBlockGiven if !block_given?
      errors.clear
      begin
        yield validation_block
      rescue HullValidationMethods::ValidationError
        return false
      end
      self.errors.empty?
    end

    def is_valid?
      self.errors.empty?
    end

    # Method to validate the presence of an attribute within a datastream
    #
    # @param [String] datastream_name The name of the datastream to validate against
    # @param [Array] fields The field to validate against - eg: [:person,:first_name]
    # @param {Hash] opts A hash containing the configurable options: currently only :message is supported 
    # @options opts [Symbol] :message The message to return if the field failed validation
    def validates_presence_of(*attr_names)
      configuration = {:message=>"is missing"}
      configuration.update(attr_names.extract_options!)
      
      datastream_name, fields = attr_names

      values = self.datastreams[datastream_name].get_values(fields)
      
      return true if !values.empty? && !values.first.empty?
      self.errors << construct_message(datastream_name,fields,configuration[:message])
      false
    end

    # Method to validate the format of an attribute within a datastream
    #
    # @param [String] datastream_name The name of the datastream to validate against
    # @param [Array] fields The field to validate against - eg: [:person,:first_name]
    # @param [Hash] opts A hash containing the configurable options: currently only :message is supported 
    # @option opts [Symbol] :with The reg exp for matching against [required]
    # @option opts [Symbol] :message The message to return if the field failed validation
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
      configuration = {:message=>"is not a member of"}
      configuration.update(attr_names.extract_options!)
      queue_name= attr_names
      if queue_membership.include?(queue_name)
        self.errors << "#{self.pid} is not a member of #{queue_name}"
      end
    end

    def validates_queue_membership_exclusive(*attr_name)
      
    end

    def construct_message(datastream_name,fields,message)
      "#{datastream_name}[#{fields.join("_")}] #{message}"
    end

    class ValidationError < RuntimeError; end # :nodoc:
    class NoValidationBlockGiven < RuntimeError; end # :nodoc:
    
end


