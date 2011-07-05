module HullModelMethods 
  

  def initialize(opts={})
    super(opts)
    change_queue_membership :proto if queue_membership.empty? && new_object?
  end

  # call insert_grant number on the descMetadata datastream
  def insert_grant_number(opts={})
    ds = self.datastreams_in_memory["descMetadata"]
    node, index = ds.insert_grant_number(opts)
    if opts[:value]
      node.inner_text = opts[:value]
    end
    return node, index
  end
  
  # call remove_grant number on the descMetadata datastream
  def remove_grant_number(index)
    ds = self.datastreams_in_memory["descMetadata"]
    result = ds.remove_grant_number(index)
    return result
  end

  # call insert_subject_topic on the descMetadata datastream
  def insert_subject_topic(opts={})
    ds = self.datastreams_in_memory["descMetadata"]
    node, index = ds.insert_subject_topic(opts)
    if opts[:value]
      node.inner_text = opts[:value]
    end
    return node, index
  end
  
  # call remove_subject_topic on the descMetadata datastream
  def remove_subject_topic(index)
    ds = self.datastreams_in_memory["descMetadata"]
    result = ds.remove_subject_topic(index)
    return result
  end

  # call insert_resource on the contentMetadata datastream
  def insert_resource(opts={})
    ds = self.datastreams["contentMetadata"]
    node, index = ds.insert_resource(opts)
    return node, index
  end
  
  # helper method to derive cmodel declaration from ruby model
  def cmodel
    model = self.class.to_s
    "info:fedora/hull-cModel:#{model[0,1].downcase + model[1..-1]}"
  end

  # overwriting to_solr to profide proper has_model_s and solrization of fedora_owner_id
  def to_solr(solr_doc=Hash.new,opts={})
    super(solr_doc,opts)
	  solr_doc << { "has_model_s" => cmodel }
    solr_doc << { "fedora_owner_id_s" => self.owner_id }
    solr_doc << { "fedora_owner_id_display" => self.owner_id }
		if ((queue_membership.include? :qa) || (queue_membership.include? :proto))
			solr_doc << { "is_member_of_queue_facet" => queue_membership.to_s }
		end
		solr_doc
  end

  def queue_membership
    self.relationships[:self].fetch(:is_member_of,[]).map{|val| HULL_QUEUES.fetch(val,"") }
  end

  def change_queue_membership(new_queue)
	  validation_method = "ready_for_#{new_queue.to_s}?".to_sym
    is_valid = self.respond_to?(validation_method) ? self.send(validation_method) : true
    
    if is_valid
      if queues =  self.queue_membership
        self.remove_relationship :is_member_of, HULL_QUEUES.invert[queues.first]
      end
      self.add_relationship :is_member_of, HULL_QUEUES.invert[new_queue]
      
      self.owner_id="fedoraAdmin" if new_queue == :qa

      return true
    else
      logger.warn "Could not change queue membership due to validation errors."
      return false
    end
  end

 	# Call to remove file obects
  def destroy_child_assets
    destroyable_child_assets.each.inject([]) do |destroyed,fo| 
        destroyed << fo.pid 
        fo.delete
        destroyed
    end

  end

  def destroyable_child_assets
    return [] unless self.file_objects
    self.file_objects.each.inject([]) do |file_assets, fo| 
      if fo.relationships[:self].has_key?(:is_part_of) && fo.relationships[:self][:is_part_of].length == 1 &&  fo.relationships[:self][:is_part_of][0].match(/#{self.pid}$/)
        file_assets << fo
      end
      file_assets
    end
  end

  #
  # Adds hull base metadata to the asset
  #
  def apply_base_metadata
		dc_ds = self.datastreams_in_memory["DC"]
		desc_ds = self.datastreams_in_memory["descMetadata"]
    #rights_ds = self.datastreams_in_memory["rightsMetadata"]
  	
		#Add the dc required elements
		dc_ds.update_indexed_attributes([:dc_identifier]=> self.pid) unless dc_ds.nil?
		dc_ds.update_indexed_attributes([:dc_genre]=>self.get_values_from_datastream("descMetadata", [:genre], {}).to_s) unless dc_ds.nil?
	
		#Add the descMetadata required elements
		desc_ds.update_indexed_attributes([:identifier]=> self.pid) unless desc_ds.nil?
		desc_ds.update_indexed_attributes([:location, :primary_display]=> "http://hydra.hull.ac.uk/resources/" + self.pid) unless desc_ds.nil?
	  return true
  end


	#
  # Adds hull additional metadata to the asset
  #
  def apply_additional_metadata
		#Here's where we call specific additional metadata changes...
		if self.respond_to?(:apply_content_specific_additional_metadata)
      self.apply_content_specific_additional_metadata
    end	
		dc_ds = self.datastreams_in_memory["DC"]
		dc_ds.update_indexed_attributes([:dc_title]=> self.get_values_from_datastream("descMetadata", [:title], {}).to_s) unless dc_ds.nil?
		dc_ds.update_indexed_attributes([:dc_dateIssued]=> self.get_values_from_datastream("descMetadata", [:origin_info,:date_issued], {}).to_s) unless dc_ds.nil?
	  return true
  end

  def valid_for_save?(params)
    if self.respond_to?(:validate_parameters)
      @pending_attributes = params
      self.validate_parameters
    end
    return self.errors.empty?
  end


end
