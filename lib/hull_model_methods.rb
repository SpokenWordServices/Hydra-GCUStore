module HullModelMethods 

  # call insert_subjec_topic on the descMetadata datastream
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

end
