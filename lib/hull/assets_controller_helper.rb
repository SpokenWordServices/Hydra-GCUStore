require "om"
module Hull::AssetsControllerHelper
  extend ActiveSupport::Concern
  include Hydra::AccessControlsEnforcement


  included do
    before_filter :enforce_access_controls, :only =>:new
    before_filter :update_set_membership, :only => :update
    before_filter :validate_parameters, :only =>[:create,:update]
  end

  ## proxies to enforce_edit_permssions. 
  def enforce_new_permissions(opts={})
    return true
  end

  # Handles updating display set & structural set associations for an object
  # @param [ActiveFedora::Base] document to update membership for. Defaults to using @document
  def update_set_membership(document=@document)
    structural = params["Structural Set"]
    structural = structural.first if structural.kind_of? Array
    if structural && structural.empty?
			 #Only set the queue membership to :proto if it doesn't have set, or already belong to proto/qa queue
			 unless document.queue_membership.to_s == "proto" || document.queue_membership.to_s == "qa"
      	document.change_queue_membership :proto
      	structural = nil
			 end
    end
    display = params["Display Set"].to_s
    display = nil if display.empty?
    if document.respond_to?(:apply_set_membership)
      document.apply_set_membership([display, structural].compact)
    end
    # when the document is a structural set, we apply the hull-apo:structuralSet as the governing apo
    # otherwise, the structural set the governing apo
    # unless the object is within queue, in which case the queue dictates the governedBy
  	 unless document.queue_membership.to_s == "proto" || document.queue_membership.to_s == "qa"
      if document.respond_to?(:apply_governed_by)
        if document.kind_of? StructuralSet
          document.apply_governed_by('hull-apo:structuralSet')
          document.copy_default_object_rights(structural.gsub("info:fedora/", '')) if structural
        elsif structural
        	document.apply_governed_by(structural)
     	 end
    	end
 		end
	end

  def validate_parameters
    logger.debug("attributes submitted: #{@sanitized_params.inspect}")
    if @document.respond_to?(:valid_for_save?)
      if !@document.valid_for_save?(@sanitized_params)
        flash[:error] = "Encountered the following errors: #{@document.errors.join("; ")}"
        redirect_to :controller => "catalog", :action=>"edit"
      end
    end
    true
  end
  
  ### Hull version calls apply_base_metadata
  def apply_depositor_metadata(asset)
	  apply_base_metadata(asset)
    if asset.respond_to?(:apply_depositor_metadata) && current_user.respond_to?(:login)
      asset.apply_depositor_metadata(current_user.login)
    end
  end

  def set_collection_type(asset, collection)
    if asset.respond_to?(:set_collection_type)
      asset.set_collection_type(collection)
    end
  end
  
  # 
  # parses your params hash, massaging them into an appropriate set of params and opts to pass into ActiveFedora::Base.update_indexed_attributes
  #
  def prep_updater_method_args
    logger.warn "DEPRECATED: Hydra::AssetsControllerHelper.prep_updater_method_args is deprecated.  Use/override sanitize_update_params instead."
    args = {:params=>{}, :opts=>{}}
    
    params["asset"].each_pair do |datastream_name,fields|
      
      args[:opts][:datastreams] = datastream_name
      
      # TEMPORARY HACK: special case for supporting textile 
      if params["field_id"]=="abstract_0" 
        params[:field_selectors] = {"descMetadata" => {"abstract" => [:abstract]}}
      end
      
      if params.fetch("field_selectors",false) && params["field_selectors"].fetch(datastream_name, false)
        # If there is an entry in field_selectors for the datastream (implying a nokogiri datastream), retrieve the field_selector for this field.
        # if no field selector, exists, use the field name
        fields.each_pair do |field_name,field_values|
          parent_select = OM.destringify( params["field_selectors"][datastream_name].fetch(field_name, field_name) )
          args[:params][parent_select] = field_values       
        end        
      else
        args[:params] = unescape_keys(params[:asset][datastream_name])
      end
    end
    
    @sanitized_params = args
    return args
     
  end

  
  # Builds a Hash that you can feed into ActiveFedora::Base.update_datstream_attributes
  # If params[:asset] is empty, returns an empty Hash
  # @return [Hash] a Hash that you can feed into ActiveFedora::Base.update_datstream_attributes
  #   {
  #    "descMetadata"=>{ [{:person=>0}, :role]=>{"0"=>"role1", "1"=>"role2", "2"=>"role3"} },
  #    "properties"=>{ "notes"=>"foo" }
  #   }
  def sanitize_update_params
    @sanitized_params ||= {}
    
    unless params["asset"].nil?
      params["asset"].each_pair do |datastream_name,fields|
      
        @sanitized_params[datastream_name] = {}
      
        # TEMPORARY HACK: special case for supporting textile 
        if params["field_id"]=="abstract_0" 
          params[:field_selectors] = {"descMetadata" => {"abstract" => [:abstract]}}
        end
      
        if params.fetch("field_selectors",false) && params["field_selectors"].fetch(datastream_name, false)
          # If there is an entry in field_selectors for the datastream (implying a nokogiri datastream), retrieve the field_selector for this field.
          # if no field selector, exists, use the field name
          fields.each_pair do |field_name,field_values|
            parent_select = OM.destringify( params["field_selectors"][datastream_name].fetch(field_name, field_name) )
            @sanitized_params[datastream_name][parent_select] = field_values       
          end        
        else
          @sanitized_params[datastream_name] = unescape_keys(params[:asset][datastream_name])
        end
      end
    end
    
    return @sanitized_params
  end
  
  # Tidies up the response from updating the document, making it more JSON-friendly
  # @param [Hash] response_from_update the response from updating the object's values
  # @return [Hash] A Hash where value of "updated" is an array with fieldname / index / value Hash for each field updated
  def tidy_response_from_update(response_from_update)
    response = Hash["updated"=>[]]
    last_result_value = ""
    response_from_update.each_pair do |field_name,changed_values|
      changed_values.each_pair do |index,value|
        response["updated"] << {"field_name"=>field_name,"index"=>index,"value"=>value} 
        last_result_value = value
      end
    end
    # If handling submission from jeditable (which will only submit one value at a time), return the value it submitted
    if params.has_key?(:field_id)
      response = last_result_value
    end
    return response
  end
  
  
  # Updates the document based on the provided parameters
  # @param [ActiveFedora::Base] document
  # @param [Hash] params should be the type expected by ActiveFedora::Base.update_datastream_attributes

  ## Hull version calls apply_additional_metadata

  def update_document(document, params)
	  # this will only work if there is only one datastream being updated.
    # once ActiveFedora::MetadataDatastream supports .update_datastream_attributes, use that method instead (will also be able to pass through params["asset"] as-is without usin prep_updater_method_args!)
    # result = document.update_indexed_attributes(params[:params], params[:opts])
    
    result = document.update_datastream_attributes(params)
    apply_base_metadata(document)
    apply_additional_metadata(document)       
  end
  
	def apply_base_metadata(asset)
		if asset.respond_to?(:apply_base_metadata)
      asset.apply_base_metadata
    end
  end

	def apply_additional_metadata(asset)
		if asset.respond_to?(:apply_additional_metadata) && current_user.respond_to?(:login)
      asset.apply_additional_metadata(current_user.login)
    end
	end

  # moved destringify into OM gem. 
  # ie.  OM.destringify( params )quit
  # Note: OM now handles destringifying params internally.  You probably don't have to do it!
  
  private
    
  def send_datastream(datastream)
    send_data datastream.content, :filename=>datastream.label, :type=>datastream.attributes["mimeType"]
  end
  
  #underscores are escaped w/ + signs, which are unescaped by rails to spaces
  def unescape_keys(attrs)
    h=Hash.new
    attrs.each do |k,v|
      h[k.gsub(/ /, '_')]=v

    end
    h
  end
  def escape_keys(attrs)
    h=Hash.new
    attrs.each do |k,v|
      h[k.gsub(/_/, '+')]=v

    end
    h
  end
  
end
