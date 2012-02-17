module HullModelMethods 
  extend ActiveSupport::Concern

  
  module ClassMethods
    def pid_namespace
      "hull-cModel"
    end
  end

  # def self.included(klass)
  #   klass.extend(ClassMethods)
  # end

  def initialize(attrs=nil)
    super(attrs)
    after_create() if new_object?
  end

  def after_create
	  change_queue_membership :proto if queue_membership.empty? && !self.kind_of?(DisplaySet)
  end

  attr_accessor :pending_attributes

  # call insert_grant number on the descMetadata datastream
  def insert_grant_number(opts={})
    ds = self.descMetadata
    node, index = ds.insert_grant_number(opts)
    if opts[:value]
      node.inner_text = opts[:value]
    end
    return node, index
  end
  
  # call remove_grant number on the descMetadata datastream
  def remove_grant_number(index)
    ds = self.descMetadata
    result = ds.remove_grant_number(index)
    return result
  end

  # call insert_subject_topic on the descMetadata datastream
  def insert_subject_topic(opts={})
    ds = self.descMetadata
    node, index = ds.insert_subject_topic(opts)
    if opts[:value]
      node.inner_text = opts[:value]
    end
    return node, index
  end
  
  # call remove_subject_topic on the descMetadata datastream
  def remove_subject_topic(index)
    self.descMetadata.remove_subject_topic(index)
  end
	
	# call insert_multi_field on datastream
	def insert_multi_field(datastream_name, fields, opts={})
	 	ds = self.datastreams[datastream_name]
    node, index = ds.insert_multi_field(fields, opts)
    if opts[:value]
      node.inner_text = opts[:value]
    end
    return node, index
	end

	# call remove_multi_field datastream
	def remove_multi_field(datastream_name, fields, index)
	 	ds = self.datastreams[datastream_name]
    result = ds.remove_multi_field(index, fields)
    return result
	end

  # call insert_resource on the contentMetadata datastream
  def insert_resource(opts={})
    node, index = self.contentMetadata.insert_resource(opts)
    return node, index
  end
  
  # call remove_resource on the contentMetadata datastream
  def remove_resource(index)
    self.contentMetadata.remove_resource(index)
  end
  
  # helper method to derive cmodel declaration from ruby model
  def cmodel
    model = self.class.to_s
    "info:fedora/hull-cModel:#{model[0,1].downcase + model[1..-1]}"
  end

  def queue_membership
    self.set_membership.map{|val| HULL_QUEUES.fetch(val,nil) }.compact
  end

	def is_governed_by_queue_membership
  	self.is_governed_by.map{|val| HULL_QUEUES.fetch(val,"") }
	end

  def is_governed_by
    self.relationships(:is_governed_by)
  end

	def set_membership
		self.relationships(:is_member_of)
	end

	def harvesting_set_membership
		self.relationships(:is_member_of_collection)
	end

  def change_queue_membership(new_queue)
	  validation_method = "ready_for_#{new_queue.to_s}?".to_sym
    is_valid = self.respond_to?(validation_method) ? self.send(validation_method) : true
    
    #All published objects should validate this step
    if new_queue == :publish
      is_valid = valid_for_publish
    end     
	
    #If the object is_valid for the next stage of queue
	  if is_valid

      queues =  self.queue_membership
      unless queues.empty?
       #If currently in a queue... Remove the queue relationnship 
       self.remove_relationship :is_member_of, HULL_QUEUES.invert[queues.first]
      end

      #Depending on the queue there is some different logic
      case new_queue
      when :publish
        #Published objects are governed by structural set
        self.apply_governed_by(structural_set)
       	if self.respond_to?(:apply_harvesting_set_membership)
          #If a harvesting set is specified add an oai_item_id
          harvesting_set = harvesting_set_membership.dup.first            
	  		  if !harvesting_set.nil?
            if !harvesting_set_membership.dup.first.empty? then add_oai_item_id end
          end
   			end
        #If the object is currently in the hidden or deleted queue, we need to change its state back to 'A' - Active
        if queues.include?(:hidden) || queues.include?(:deleted) then self.inner_object.state = "A" end    
      when :qa
        #When objects are moved into the QA queue owner_id, and governed by changes to contentAccessTeam... No longer 'owned' by creator
        self.add_relationship :is_member_of, HULL_QUEUES.invert[new_queue]
 	      self.owner_id="fedoraAdmin"
        apply_governed_by(HULL_QUEUES.invert[new_queue]) #We want to load the QAQueue defaultObjectrights into object rightsMetadata
      when :hidden, :deleted
        #When objects are moved to the hidden, or deleted queue, we change the object state to 'D' - Deleted
        self.add_relationship :is_member_of, HULL_QUEUES.invert[new_queue]
        self.apply_governed_by(HULL_QUEUES.invert[new_queue]) #We want to load the hidden/deleted defaultObjectrights into object rightsMetadata
        self.inner_object.state = "D"         
      else
          self.add_relationship :is_member_of, HULL_QUEUES.invert[new_queue]
          self.add_relationship :is_governed_by, HULL_QUEUES.invert[new_queue]
      end      
      return true
    else
      logger.warn "Could not change queue membership due to validation errors."
      return false
    end
  end

  #Valid for publish checks for member of structural set
  def valid_for_publish
		valid = true
  	if structural_set.nil?
   		errors << "Structural Set> Error: No set selected"
			valid = false
  	end
		valid
 	end

  #
  # Adds hull base metadata to the asset
  #
  def apply_base_metadata
		dc_ds = self.dc
		desc_ds = self.descMetadata

	 	#Here's where we call specific additional metadata changes...
		if self.respond_to?(:apply_specific_base_metadata)
      self.apply_specific_base_metadata
    end	

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
			
		dc_ds = self.dc
		descMetadata_ds = self.descMetadata

    unless dc_ds.nil?
      dc_ds.update_indexed_attributes([:dc_title]=> self.get_values_from_datastream("descMetadata", [:title], {}).to_s)
      begin
        date_issued = self.get_values_from_datastream("descMetadata", [:origin_info,:date_issued], {})
				date_valid = self.get_values_from_datastream("descMetadata", [:origin_info,:date_valid], {})
       
        if date_issued.to_s != ""
        	dc_ds.update_indexed_attributes([:dc_date]=> date_issued.to_s) if date_issued.present?
				else
					dc_ds.update_indexed_attributes([:dc_date]=> date_valid.to_s) if date_valid.present?
				end
      rescue OM::XML::Terminology::BadPointerError => e
        logger.error "ERROR when trying to copy date on #{self.class} #{self.pid}:\n\t#{e.message}"
      end
    end
	
		unless descMetadata_ds.nil?
			descMetadata_ds.update_indexed_attributes ([:record_info,:record_change_date] => Time.now.strftime("%Y-%m-%d"))
		end

		self.label = generate_object_label
		
	  return true
  end

	#method to generate fedora object  in the form of 'TITLE - AUTHORS;'
	def generate_object_label
 		label = ""
    label_names = " - "
		begin
			names = self.get_values_from_datastream("descMetadata", [:name, :namePart], {})
			roles = self.get_values_from_datastream("descMetadata", [:name, :role, :text], {}) 
			#'zip' name into role array
			role_name = roles.zip(names)
	    role_name.each do |person|
			  role = person[0].to_s.downcase
			 	if role  == 'creator' || role == 'author'
					label_names = label_names + person[1] + '; '
				end		
	    end
		rescue OM::XML::Terminology::BadPointerError => e
			#Assume that its an object without author (Set or alike)
			label_names = ""
		end
		title = self.get_values_from_datastream("descMetadata", [:title], {}).to_s

		#truncate the title if its too long
		title = title.length > 40 ? title[0..40] <<'...': title unless title.nil?
		label =  title + label_names
	
		return label
  end

  def structural_set
    ids = set_membership
    return unless ids.present?
    (ids & StructuralSet.structural_set_pids - HULL_QUEUES.keys).first
  end
  def display_set
    ids = set_membership
    return unless ids.present?
    (ids & DisplaySet.display_set_pids).first
  end
  def harvesting_set
    ids = harvesting_set_membership
    return unless ids.present?
    (ids & HarvestingSet.harvesting_set_pids).first
  end

  # def top_level_collection
  #   return unless relationships[:self][:is_member_of]
  #   graph = DisplaySet.parent_graph
  #   ptr = (relationships[:self][:is_member_of] & graph.keys).first
  #   return if ptr == 'info:fedora/hull:rootDisplaySet'
  #   while graph[ptr][:parent] != 'info:fedora/hull:rootDisplaySet' do
  #     ptr = graph[ptr][:parent]
  #   end
  #   
  #   return graph[ptr]
  # end

  # Associate the given sets with the object, removing old associations first.
  # @param [Array] sets to set associations with. Should be URIs.
	def apply_set_membership(sets)
		#We delete previous set memberships and move to new set
    old_sets = set_membership.dup
    old_sets.each { |s| self.remove_relationship(:is_member_of, s) unless HULL_QUEUES.has_key?(s) }
    sets.delete_if { |s| s == ""}.each { |s| self.add_relationship :is_member_of, s }
	end

	def apply_governed_by(set)
	
    set = StructuralSet.find(set.gsub("info:fedora/", "")) if set.kind_of? String
		#We delete previous is_governed_by relationships and add the new one
    old_governed_by = is_governed_by
    unless old_governed_by.include? "info:fedora/#{set.pid}"
      old_governed_by.each { |g| self.remove_relationship :is_governed_by, g }
      self.add_relationship :is_governed_by, set 
      copy_rights_metadata(set)
    end
	end

  #
  # Adds metadata about the depositor to the asset
  # Most important behavior: if the asset has a rightsMetadata datastream, this method will add +depositor_id+ to its individual edit permissions.
  #
  def apply_depositor_metadata(depositor_id, depositor_email)
    prop_ds = self.datastreams["properties"]
    rights_ds = self.datastreams["rightsMetadata"]
  
    if !prop_ds.nil? && prop_ds.respond_to?(:depositor_values)
     prop_ds.depositorEmail_values = depositor_email unless prop_ds.nil?
     prop_ds.depositor_values = depositor_id unless prop_ds.nil?
    end
    rights_ds.update_indexed_attributes([:edit_access, :person]=>depositor_id) unless rights_ds.nil?
    return true
  end

  def copy_rights_metadata(apo)
		rights = Hydra::RightsMetadata.new(self.inner_object, 'rightsMetadata')
    rights.ng_xml = apo.defaultObjectRights.content
    defaultRights = NonindexingRightsMetadata.new(self.inner_object, 'defaultObjectRights')
    defaultRights.ng_xml = rights.ng_xml.dup
    datastreams["rightsMetadata"] = rights 
    datastreams["defaultObjectRights"] = defaultRights if datastreams.has_key? "defaultObjectRights"

		#If this is a UketdObject we need to copy the rights over for the children
		if self.class == UketdObject
			file_assets = parts_ids
			#Loop through the file_assets and copy the new rights
			file_assets.each do |file_asset_pid|
				file_asset = ActiveFedora::Base.load_instance(file_asset_pid)
				rights = Hydra::RightsMetadata.new(file_asset.inner_object, 'rightsMetadata')
   			rights.ng_xml = apo.defaultObjectRights.content
    		file_asset.datastreams["rightsMetadata"] = rights
				file_asset.save				
			end
		end
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

	  #This makes sure that active_fedora_model_s gets set to correct class instead of just 'ActiveFedora::Base' 
		solr_doc["active_fedora_model_s"] = self.class.to_s 

	  solr_doc["has_model_s"] = cmodel
    solr_doc["fedora_owner_id_s"] = self.owner_id
    solr_doc["fedora_owner_id_display"] = self.owner_id
		if ((queue_membership.include? :qa) || (queue_membership.include? :proto) || (queue_membership.include? :hidden) || (queue_membership.include? :deleted))
      #Set the is_member_of_queue_facet solr field if it is in a 'queue'... 
      if queue_membership.include? :qa then queue_facet = "QA" else queue_facet = queue_membership.to_s.capitalize end
			solr_doc["is_member_of_queue_facet"] = queue_facet
		end

		#get Time object representation of the date information in object (to enable sort)
		date = get_object_sortable_date
		if !date.nil?
 			solr_doc.merge!({"year_facet" => date.year, "month_facet" => date.month, "sortable_date_dt" => date.iso8601.to_s + "Z"})
		end

    if display_set
      collection = display_set
      solr_doc["top_level_collection_id_s"] = collection if collection
    end
    solr_doc["text"] = get_extracted_content
		solr_doc
  end

  def get_extracted_content
    retrieve_child_asset_pdf_content + retrieve_internal_datastream_pdf_content
  end

	#This section of code deals with selecting a date from the descMetadata (either date_issued or date_valid)
	#and reading it into a Ruby Time type. If both date_issued and date_valid exist, preference will be giving to the latter... 
	#This method will deal with date metadata populated as '2001/2002' type dates; it will select the latter date year.
	def get_object_sortable_date
		date = nil
    if descMetadata.origin_info && (descMetadata.origin_info.date_issued || descMetadata.origin_info.date_valid)
			begin
				date_valid = descMetadata.origin_info.date_valid.first.to_s
				date_issued = descMetadata.origin_info.date_issued.first.to_s
					
				if date_valid.size > 0
					date_valid = descMetadata.origin_info.date_valid.first
					if date_valid.include? "/"
							val = to_long_date(date_valid[date_valid.index('/')+1..date_valid.size])
					else
							val = to_long_date(date_valid) 
					end
				elsif	date_issued.size > 0
					if date_issued.include? "/"
							val = to_long_date(date_issued[date_issued.index('/')+1..date_issued.size])
					else			
						val = to_long_date(descMetadata.origin_info.date_issued.first)
					end
				end
 				if val
					date = Time.parse val
				end
			rescue ArgumentError => e
        #nop
      end
		end
	end


	#Add OAI Item id to RELS-EXT eg.
	#<oai:itemID>oai:hull.ac.uk:hull:4649</oai:itemID>
	def add_oai_item_id
		#literal specifies that it should be in the form of...<oai:itemID>...</oai:itemID>
 		self.add_relationship :oai_item_id, "oai:hull.ac.uk:" + self.pid, :literal => true
	end

  # Extract content from all child assets with a content datastream with a mime type of application/pdf
  def retrieve_child_asset_pdf_content
    content = parts.each.inject("") do |extracted_content, child|
      if child.datastreams.keys.include?("content") and child.datastreams["content"].mimeType == 'application/pdf'
        extracted_content << datastream_content(child.pid,child.datastreams["content"])
        extracted_content << " "
      end
      extracted_content
    end
  end

  # Extract content from all internal datastreams where mime type is application/pdf
  def retrieve_internal_datastream_pdf_content
    content = datastreams.values.each.inject("") do |extracted_content, datastream|
      if datastream.mimeType == 'application/pdf'
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
    logger.error "Extracting content from #{filename.path}"
    url = "#{ActiveFedora.solr_config[:url]}/update/extract?defaultField=content&extractOnly=true"
    begin
      response = RestClient.post url, :upload => filename
    rescue RestClient::InternalServerError => e
      xml = Nokogiri.parse e.http_body
      logger.error "Unable to extract content:\nRequest: #{url}\nResponse: #{xml.css("pre").text}"
      return ""
    rescue RestClient::ResourceNotFound => e
      xml = Nokogiri.parse e.http_body
      logger.error "Unable to extract content-- Resource not found:\nRequest: #{url}\nResponse: #{xml.css("pre").text}"
      return ""
    rescue Exception => e
      logger.error "Unable to extract:\n#{e.inspect}"
      return ""
    end
    ng_xml = Nokogiri::XML.parse(response.body)
    ele = ng_xml.at_css("str")
    unless ele
      logger.error "Unable to get the 'str' node from response: #{response.body}"
      return ""
    end
    ele.inner_html
  end

end
