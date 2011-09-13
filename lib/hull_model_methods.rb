module HullModelMethods 
  
  module ClassMethods
    def pid_namespace
      "hull-cModel"
    end
     
  end

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  def initialize(opts={})
    super(opts)
    after_create() if new_object?
  end

  def after_create
	  change_queue_membership :proto if queue_membership.empty? && !self.kind_of?(DisplaySet)
  end

  attr_accessor :pending_attributes

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
	
	# call insert_multi_field on datastream
	def insert_multi_field(datastream_name, fields, opts={})
	 	ds = self.datastreams_in_memory[datastream_name]
    node, index = ds.insert_multi_field(fields, opts)
    if opts[:value]
      node.inner_text = opts[:value]
    end
    return node, index
	end

	# call remove_multi_field datastream
	def remove_multi_field(datastream_name, fields, index)
		ds = self.datastreams_in_memory[datastream_name]
    result = ds.remove_multi_field(index, fields)
    return result
	end

  # call insert_resource on the contentMetadata datastream
  def insert_resource(opts={})
    ds = self.datastreams["contentMetadata"]
    node, index = ds.insert_resource(opts)
    return node, index
  end
  
  # call remove_resource on the contentMetadata datastream
  def remove_resource(index)
    ds = self.datastreams_in_memory["contentMetadata"]
    result = ds.remove_resource(index)
    return result
  end
  
  # helper method to derive cmodel declaration from ruby model
  def cmodel
    model = self.class.to_s
    "info:fedora/hull-cModel:#{model[0,1].downcase + model[1..-1]}"
  end

#  # overwriting to_solr to profide proper has_model_s and solrization of fedora_owner_id
#  def to_solr(solr_doc=Hash.new,opts={})
#    super(solr_doc,opts)
#	  solr_doc << { "has_model_s" => cmodel }
#    solr_doc << { "fedora_owner_id_s" => self.owner_id }
#    solr_doc << { "fedora_owner_id_display" => self.owner_id }
#		if ((queue_membership.include? :qa) || (queue_membership.include? :proto))
#			solr_doc << { "is_member_of_queue_facet" => queue_membership.to_s }
#		end
#		solr_doc
#  end

  def queue_membership
    self.relationships[:self].fetch(:is_member_of,[]).map{|val| HULL_QUEUES.fetch(val,"") }
  end

	def is_governed_by_queue_membership
  	self.relationships[:self].fetch(:is_governed_by,[]).map{|val| HULL_QUEUES.fetch(val,"") }
	end

  def is_governed_by
    self.relationships[:self].fetch(:is_governed_by,[])
  end

	def set_membership
		self.relationships[:self].fetch(:is_member_of,[])
	end

  def change_queue_membership(new_queue)
	  validation_method = "ready_for_#{new_queue.to_s}?".to_sym
    is_valid = self.respond_to?(validation_method) ? self.send(validation_method) : true
    
    if is_valid
      if queues =  self.queue_membership
        self.remove_relationship :is_member_of, HULL_QUEUES.invert[queues.first]
				self.remove_relationship :is_governed_by, HULL_QUEUES.invert[queues.first]
      end
      self.add_relationship :is_member_of, HULL_QUEUES.invert[new_queue]
			self.add_relationship :is_governed_by, HULL_QUEUES.invert[new_queue]
      
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
  def apply_additional_metadata(depositor_id)
		#Here's where we call specific additional metadata changes...
		if self.respond_to?(:apply_content_specific_additional_metadata)
      self.apply_content_specific_additional_metadata
    end	

		#We are setting the ownerId within apply_addtional_metadata due to a Fedora bug (FCREPO-963 - which means we can't set it on ingest).
		#It only sets the ownerId with the depositor id if its in the proto queue
 		if self.queue_membership.include? :proto
			self.owner_id = depositor_id
		end
			
		dc_ds = self.datastreams_in_memory["DC"]
    unless dc_ds.nil?
      dc_ds.update_indexed_attributes([:dc_title]=> self.get_values_from_datastream("descMetadata", [:title], {}).to_s)
      begin
        date_issued = self.get_values_from_datastream("descMetadata", [:origin_info,:date_issued], {})
        dc_ds.update_indexed_attributes([:dc_dateIssued]=> date_issued.to_s) if date_issued.present?
      rescue OM::XML::Terminology::BadPointerError => e
        logger.error "ERROR when trying to copy date issued on #{self.class} #{self.pid}:\n\t#{e.message}"
      end
    end
	  return true
  end

  def structural_set
    return unless relationships[:self][:is_member_of]
    (relationships[:self][:is_member_of] & StructuralSet.structural_set_pids).first
  end
  def display_set
    return unless relationships[:self][:is_member_of]
    (relationships[:self][:is_member_of] & DisplaySet.display_set_pids).first
  end

  def top_level_collection
    return unless relationships[:self][:is_member_of]
    graph = DisplaySet.parent_graph
    ptr = (relationships[:self][:is_member_of] & graph.keys).first
    return if ptr == 'info:fedora/hull:rootDisplaySet'
    while graph[ptr][:parent] != 'info:fedora/hull:rootDisplaySet' do
      ptr = graph[ptr][:parent]
    end
    
    return graph[ptr]
  end

	def apply_set_membership(sets)
		#We delete previous set memberships and move to new set
    old_sets = set_membership.dup
    old_sets.each { |s| self.remove_relationship :is_member_of, s }
    sets.delete_if { |s| s == ""}.each { |s| self.add_relationship :is_member_of, s }
	end

	def apply_governed_by(set)
    set = StructuralSet.find(set) if set.kind_of? String
		#We delete previous is_governed_by relationships and add the new one
    old_governed_by = is_governed_by
    unless old_governed_by.include? "info:fedora/#{set.pid}"
      old_governed_by.each { |g| self.remove_relationship :is_governed_by, g }
      self.add_relationship :is_governed_by, set 
      copy_rights_metadata(set)
    end
	end

  def copy_rights_metadata(apo)
    rights = Hydra::RightsMetadata.from_xml(apo.defaultObjectRights.content)
    rights.pid = self.pid
    defaultRights = rights.dup
    rights.dsid = "rightsMetadata"
    defaultRights.dsid = "defaultObjectRights"
    datastreams_in_memory["rightsMetadata"] = rights 
    datastreams_in_memory["defaultObjectRights"] = defaultRights if datastreams.has_key? "defaultObjectRights"
  end

  def valid_for_save?(params)
    if self.respond_to?(:validate_parameters)
      @pending_attributes = params
      self.validate_parameters
    end
    return self.errors.empty?
  end

	#This method will validate that dates in the following formats are valid:-
	# YYYY-MM-DD
  # YYYY-MM
  # YYYY
  # For example 2008-12-01 is valid
  #							2008-30-60 is invalid 
	def validates_datastream_date(*attr_names)
		datastream_name, fields = attr_names
		values = self.datastreams[datastream_name].get_values(fields)
 		if !values.empty? && !values.first.empty?
    	values.each_with_index do |val,index|
				validates_date(val)
			end
		end	
	end

	def validates_date(date)
		begin
			Date.parse(to_long_date(date))
		rescue
			errors << "descMetadata->Date error: Invalid date"
		end		
	end
	
	#Quick utility method used to get long version of a date (YYYY-MM-DD) from short form (YYYY-MM) - Defaults 01 for unknowns
	def to_long_date(flexible_date)
		full_date = ""
		if flexible_date.match(/^\d{4}$/)
			full_date = flexible_date + "-01-01"
		elsif flexible_date.match(/^\d{4}-\d{2}$/)
			full_date = flexible_date +  "-01"
		elsif flexible_date.match(/^\d{4}-\d{2}-\d{2}$/)
			full_date = flexible_date
		end
		return full_date
	end
  
  def to_solr(solr_doc=Hash.new, opts={})
    super(solr_doc,opts)
	  solr_doc << { "has_model_s" => cmodel }
    solr_doc << { "fedora_owner_id_s" => self.owner_id }
    solr_doc << { "fedora_owner_id_display" => self.owner_id }
		if ((queue_membership.include? :qa) || (queue_membership.include? :proto))
			solr_doc << { "is_member_of_queue_facet" => queue_membership.to_s }
		end
    if descMetadata.origin_info && descMetadata.origin_info.date_issued 
      begin
        val = descMetadata.origin_info.date_issued.first
        if val
          date = Date.parse val
          solr_doc << {"year_facet" => date.year, "month_facet" => date.month} 
        end
      rescue ArgumentError => e
        #nop
      end
    end
    if display_set
      collection = top_level_collection
      solr_doc << {"top_level_collection_id_s" => 'info:fedora/' + collection[:pid]} if collection
    end
    solr_doc << {"text" => get_extracted_content }
		solr_doc
  end

  def get_extracted_content
    retrieve_child_asset_pdf_content + retrieve_internal_datastream_pdf_content
  end

  # Extract content from all child assets with a content datastream with a mime type of application/pdf
  def retrieve_child_asset_pdf_content
    content = parts.each.inject("") do |extracted_content, child|
      if child.datastreams.keys.include?("content") and child.datastreams["content"].mime_type == 'application/pdf'
        extracted_content << datastream_content(child.pid,child.datastreams["content"])
        extracted_content << " "
      end
      extracted_content
    end
  end

  # Extract content from all internal datastreams where mime type is application/pdf
  def retrieve_internal_datastream_pdf_content
    content = datastreams.values.each.inject("") do |extracted_content, datastream|
      if datastream.mime_type == 'application/pdf'
        extracted_content << datastream_content(pid,datastream)
        extracted_content << " "
      end
      extracted_content
    end
  end

  def datastream_content(pid,datastream)
    io = Tempfile.new("#{pid.gsub(':','_')}_#{datastream.dsid}")
    io.write datastream.content
    io.rewind
    datastream_content = extract_content(io)
    io.unlink
    datastream_content
  end

  def extract_content(filename)
    url = "#{ActiveFedora.solr_config[:url]}/update/extract?defaultField=content&extractOnly=true"
    begin
      response = RestClient.post url, :upload => filename
    rescue RestClient::InternalServerError => e
      xml = Nokogiri.parse e.http_body
      logger.error "Unable to extract content:\nRequest: #{url}\nResponse: #{xml.css("pre").text}"
      return ""
    rescue Exception => e
      logger.error "Unable to extract:\n#{e.inspect}"
      return ""
    end
    ng_xml = Nokogiri::XML.parse(response.body)
    ele = ng_xml.at_css("str")
    ele.inner_html
  end

end
