require 'hydra'

class ExamPaper < ActiveFedora::Base

  include Hydra::ModelMethods
  include HullModelMethods
  include HullValidationMethods

  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 

  has_metadata :name => "descMetadata", :type => Hydra::ModsExamPaper

  has_metadata :name => "contentMetadata", :type => ContentMetadata

  has_metadata :name => "DC", :type => ObjectDc, :content_type => "Examination paper"

  has_datastream :name=>"content", :type=>ActiveFedora::Datastream, :mimeType=>"application/pdf", :controlGroup=>'M'

  # A place to put extra metadata values
  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'collection', :string
    m.field 'depositor', :string
  end

    
  has_validation :valid_for_submit? do 
    validates_presence_of "descMetadata",[:module,:code]
    validates_presence_of("descMetadata",[:module,:name])
    validates_presence_of("descMetadata",[:origin_info,:date_issued])
    validates_format_of("descMetadata",[:origin_info,:date_issued], :with=> /(January|February|March|April|May|June|July|August|September|October|November|December) \d{4}/)
    is_valid?
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
end
