require "hydra"
require 'rest_client'
require 'tempfile'
require 'net/http/post/multipart'

class UketdObject < ActiveFedora::Base
  
  include Hydra::ModelMethods
  include HullModelMethods
  include HullValidationMethods

  def initialize(attrs={})
    super(attrs)
    if new_object?
      self.add_relationship(:has_model,"info:fedora/hydra-cModel:genericParent")
      self.add_relationship(:has_model,"info:fedora/hydra-cModel:commonMetadata")
    end
  end

  has_relationship "parts", :is_part_of, :inbound => true
  
  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 
  
  # Uses the Hydra MODS Article profile for tracking most of the descriptive metadata
  # TODO: define terminology for ETD
  has_metadata :name => "descMetadata", :type => ModsUketd

  has_metadata :name => "UKETD_DC", :type => ActiveFedora::NokogiriDatastream

  has_metadata :name => "DC", :type => ObjectDc

  has_metadata :name => "contentMetadata", :type => ContentMetadata

  # A place to put extra metadata values
  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'collection', :string
    m.field 'depositor', :string
  end

  has_workflow_validation :qa do
    errors << "#{pid} is already in qa queue" if queue_membership.include? :qa
    validates_presence_of "descMetadata",[:title]
    validates_presence_of("descMetadata",[:name,:namePart])
    validates_presence_of("descMetadata",[:subject_topic])
    validates_presence_of("descMetadata",[:language,:lang_code])
    validates_presence_of("descMetadata",[:origin_info,:publisher])
    validates_presence_of("descMetadata",[:qualification_level])
    validates_presence_of("descMetadata",[:qualification_name])
    validates_format_of("descMetadata",[:origin_info,:date_issued], :with=> /^(\d{4}-\d{2}-\d{2}|\d{4}-\d{2}|\d{4})/) #Checks date format for ETDS we are flexible
		validates_datastream_date("descMetadata",[:origin_info,:date_issued]) #Checks that the actual date is valid
    is_valid?
  end

  has_validation :validate_parameters do
    if @pending_attributes.fetch("descMetadata",nil)
      errors << "descMetadata->title error: missing title" if @pending_attributes["descMetadata"][[:title_info,:main_title]]["0"].empty?
      errors << "descMetadata->author error: missing author" if @pending_attributes["descMetadata"][[{:person=>0},:namePart]]["0"].empty?
			validates_date(@pending_attributes["descMetadata"][[:origin_info,:date_issued]]["0"]) if !@pending_attributes["descMetadata"][[:origin_info,:date_issued]]["0"].empty? #Only validate if its specified
    end
    is_valid?
  end

  def apply_content_specific_additional_metadata

    if self.queue_membership.include? :proto
      desc_ds = self.datastreams_in_memory["descMetadata"]
      module_date = self.get_values_from_datastream("descMetadata", [:origin_info,:date_issued], {}).to_s
      
      if module_date.empty?
        module_date = ""
      else
        module_date = Date.parse(to_long_date(module_date)).strftime("%Y")
      end   
      
      rights = "© " + module_date + " The Author. " + "All rights reserved. No part of this publication may be reproduced without the written permission of the copyright holder."
      desc_ds.update_indexed_attributes([:rights] => rights) unless desc_ds.nil?
      # ETDs can only be submitted in English
      desc_ds.update_indexed_attributes([:language, :lang_code] => "eng", [:language, :lang_text] => "English") unless desc_ds.nil?
      
      # Need to create publisher from department and institution ie "Computer Science, The University of Hull"      
    end
  end
  
  def file_objects_append(obj)
    super(obj)
    # add handler for updating contentMetadata datastreams    
  end
    
  def self.person_relator_terms
    {"aut" => "Author",
     "adv" => "Supervisor"
     }
  end

  def to_solr(solr_doc=Hash.new, opts={})
    super(solr_doc,opts)
	  solr_doc << { "has_model_s" => cmodel }
    solr_doc << { "fedora_owner_id_s" => self.owner_id }
    solr_doc << { "fedora_owner_id_display" => self.owner_id }
		if ((queue_membership.include? :qa) || (queue_membership.include? :proto))
			solr_doc << { "is_member_of_queue_facet" => queue_membership.to_s }
		end
    solr_doc << {"content" => get_extracted_content }
		solr_doc
  end

  def get_extracted_content
    content = parts.each.inject([]) do |contents, child|
      if child.datastreams.keys.include?("content") and child.datastreams["content"].mime_type == 'application/pdf'
        io = Tempfile.new("#{child.pid.gsub(':','_')}_content")
        io.write child.datastreams["content"].content
        io.rewind
        contents << extract_content(io)
        io.unlink
      end
      contents
    end
    content.join(" ")
  end

  def extract_content(filename)
    url = "localhost:8983/solr/development/update/extract?defaultField=content&extractOnly=true"
    response = RestClient.post url, :upload => filename
    ng_xml = Nokogiri::XML.parse(response.body)
    ele = ng_xml.at_css("str")
    ele.inner_html
  end

end
