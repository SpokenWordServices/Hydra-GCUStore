require "hydra"

class UketdObject < ActiveFedora::Base
  
  include Hydra::ModelMethods
  include HullModelMethods
  include HullValidationMethods

  has_relationship "parts", :is_part_of, :inbound => true
  
  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 
  
  # Uses the Hydra MODS Article profile for tracking most of the descriptive metadata
# TODO: define terminology for ETD
  has_metadata :name => "descMetadata", :type => HullModsEtd

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
    is_valid?
  end

  def apply_content_specific_additional_metadata

    if self.queue_membership.include? :proto
      desc_ds = self.datastreams_in_memory["descMetadata"]
      module_date = self.get_values_from_datastream("descMetadata", [:origin_info,:date_issued], {}).to_s
      rights = "© " + module_date[-4,4] + " The Author. " + "All rights reserved. No part of this publication may be reproduced without the written permission of the copyright holder."
      
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
     "adv" => "Thesis advisor"
     }
  end

end
