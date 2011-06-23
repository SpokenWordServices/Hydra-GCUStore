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
    ds = self.datastreams_in_memory["contentMetadata"]
    node, index = ds.insert_resource(opts)
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

  
end

