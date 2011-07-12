require 'hydra'

class ExamPaper < ActiveFedora::Base

  include Hydra::ModelMethods
  include HullModelMethods
  include HullValidationMethods

  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 

  has_metadata :name => "descMetadata", :type => Hydra::ModsExamPaper

  has_metadata :name => "contentMetadata", :type => ContentMetadata

  has_metadata :name => "DC", :type => ObjectDc

  has_datastream :name=>"content", :type=>ActiveFedora::Datastream, :mimeType=>"application/pdf", :controlGroup=>'M'

  # A place to put extra metadata values
  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'collection', :string
    m.field 'depositor', :string
  end

    
  has_workflow_validation :qa do
    errors << "#{pid} is already in qa queue" if queue_membership.include? :qa
    validates_presence_of "descMetadata",[:module,:code]
    validates_presence_of("descMetadata",[:module,:name])
    validates_presence_of("descMetadata",[:origin_info,:date_issued])
    validates_format_of("descMetadata",[:origin_info,:date_issued], :with=> /(January|February|March|April|May|June|July|August|September|October|November|December) \d{4}/)
    validates_presence_of("descMetadata",[:title])
    is_valid?
  end
  
  has_validation :validate_parameters do
    if @pending_attributes.fetch("descMetadata",nil)
      errors << "descMetadata error: missing module code" if @pending_attributes["descMetadata"][[:module,:code]]["0"].empty?
      errors << "descMetadata error: missing module name" if @pending_attributes["descMetadata"][[:module,:name]]["0"].empty?
      errors << "descMetadata error: missing examination date" if @pending_attributes["descMetadata"][[:origin_info,:date_issued]]["0"].empty?
      errors << "descMetadata error: missing department" if @pending_attributes["descMetadata"][[:organization,:namePart]]["0"].empty?
    end
    is_valid?
  end

  def apply_content_specific_additional_metadata

    if self.queue_membership.include? :proto
      desc_ds = self.datastreams_in_memory["descMetadata"]
      module_code = self.get_values_from_datastream("descMetadata", [:module, :code], {}).to_s
      module_name = self.get_values_from_datastream("descMetadata", [:module,:name], {}).to_s
      module_date = self.get_values_from_datastream("descMetadata", [:origin_info,:date_issued], {}).to_s
      exam_title = (module_code + " " + module_name + " " + "(" + module_date + ")")
      display_title = (module_code + " " + module_name)
      rights = "© " + module_date[-4,4] + " " + self.get_values_from_datastream("descMetadata", [:origin_info, :publisher], {}).to_s.gsub(/\n/,'').strip + ". " + "All rights reserved. No part of this publication may be reproduced without the written permission of the copyright holder."
      
      desc_ds.update_indexed_attributes([:title] => exam_title) unless desc_ds.nil?
      desc_ds.update_indexed_attributes([:module, :combined_display] => display_title) unless desc_ds.nil?
      desc_ds.update_indexed_attributes([:language, :lang_code] => self.get_values_from_datastream("descMetadata", [:language, :lang_code], {}).to_s) unless desc_ds.nil?
      desc_ds.update_indexed_attributes([:rights] => rights) unless desc_ds.nil?
      
    end
  end
  
end
