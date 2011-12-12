require 'hydra'

class ExamPaper < ActiveFedora::Base

  include Hydra::ModelMethods
  include HullModelMethods
  include HullValidationMethods

  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :label=>"Rights metadata", :type => Hydra::RightsMetadata 

  has_metadata :name => "descMetadata", :type => ModsExamPaper, :label=>"MODS metadata"

  has_metadata :name => "contentMetadata", :label=>"Content metadata", :type => ContentMetadata

  has_metadata :name => "DC", :label=>"DC admin metadata",  :type => ObjectDc

  has_datastream :name=>"content", :label=>"content", :type=>ActiveFedora::Datastream, :mimeType=>"application/pdf", :controlGroup=>'M'

  # A place to put extra metadata values
  has_metadata :name => "properties", :label=>"Workflow properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'collection', :string
    m.field 'depositor', :string
  end

    
  has_workflow_validation :qa do
    errors << "#{pid} is already in qa queue" if queue_membership.include? :qa
    validates_presence_of "descMetadata",[:module,:code]
    validates_presence_of("descMetadata",[:module,:name])
    validates_presence_of("descMetadata",[:origin_info,:date_issued])
    validates_format_of("descMetadata",[:origin_info,:date_issued], :with=> /^\d{4}-\d{2}$/) #Checks date format for Exam papers (YYYY-MM)
    validates_presence_of("descMetadata",[:title])
		validates_datastream_date("descMetadata",[:origin_info,:date_issued]) #Checks that the actual date is valid
    is_valid?
  end
  
  has_validation :validate_parameters do
    if @pending_attributes.fetch("descMetadata",nil)
      errors << "descMetadata error: missing module code" if @pending_attributes["descMetadata"][[:module,:code]]["0"].empty?
      errors << "descMetadata error: missing module name" if @pending_attributes["descMetadata"][[:module,:name]]["0"].empty?
      errors << "descMetadata error: missing examination date" if @pending_attributes["descMetadata"][[:origin_info,:date_issued]]["0"].empty?
      errors << "descMetadata error: missing department" if @pending_attributes["descMetadata"][[:organization,:namePart]]["0"].empty?
			errors << "descMetadata error: invalid date format (should be YYYY-MM)" if !@pending_attributes["descMetadata"][[:origin_info,:date_issued]]["0"].match(/^\d{4}-\d{2}$/)
			validates_date(@pending_attributes["descMetadata"][[:origin_info,:date_issued]]["0"]) #Checks that the actual date is valid	
		end		
    is_valid?
  end

  def apply_content_specific_additional_metadata

    if self.queue_membership.include? :proto
      desc_ds = self.datastreams_in_memory["descMetadata"]
      module_code = self.get_values_from_datastream("descMetadata", [:module, :code], {}).to_s
      module_name = self.get_values_from_datastream("descMetadata", [:module,:name], {}).to_s
      module_date = self.get_values_from_datastream("descMetadata", [:origin_info,:date_issued], {}).to_s
			
			friendly_module_date = Date.parse(to_long_date(module_date)).strftime("%B") + " " + Date.parse(to_long_date(module_date)).strftime("%Y")
	
			exam_title = (module_code + " " + module_name + " " + "(" + friendly_module_date + ")")
      display_title = (module_code + " " + module_name)
      rights = "© " + Date.parse(to_long_date(module_date)).strftime("%Y") + " " + self.get_values_from_datastream("descMetadata", [:origin_info, :publisher], {}).to_s.gsub(/\n/,'').strip + ". " + "All rights reserved. No part of this publication may be reproduced without the written permission of the copyright holder."
      
      desc_ds.update_indexed_attributes([:title] => exam_title) unless desc_ds.nil?
      desc_ds.update_indexed_attributes([:module, :combined_display] => display_title) unless desc_ds.nil?
       #Examination papers can only be submitted in English
      desc_ds.update_indexed_attributes([:language, :lang_code] => "eng", [:language, :lang_text] => "English") unless desc_ds.nil?
      
      desc_ds.update_indexed_attributes([:rights] => rights) unless desc_ds.nil?
      
    end
  end

  # Overridden so that we can store a cmodel and "complex Object"
  def assert_content_model
    add_relationship(:has_model, "info:fedora/hull-cModel:examPaper")
    add_relationship(:has_model, "info:fedora/hydra-cModel:compoundContent")
    add_relationship(:has_model, "info:fedora/hydra-cModel:commonMetadata")
  end  
end
