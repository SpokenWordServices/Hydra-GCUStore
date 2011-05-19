require 'hydra'

class ExamPaper < ActiveFedora::Base

  include Hydra::ModelMethods
  include HullModelMethods

  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 

  has_metadata :name => "descMetadata", :type => Hydra::ModsExamPaper

  has_metadata :name => "contentMetadata", :type => ContentMetadata

  has_metadata :name => "DC", :type => ActiveFedora::NokogiriDatastream

  # A place to put extra metadata values
  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'collection', :string
    m.field 'depositor', :string
  end

end
