require "hydra"

class JournalArticle < ActiveFedora::Base
  
  include Hydra::ModelMethods
  include HullModelMethods
  include HullValidationMethods
	include ActiveFedora::ServiceDefinitions
	include CommonMetadataSdef

	#We want the RELS-EXT to be X and have label
  self.ds_specs = {'RELS-EXT'=> {:type=> ActiveFedora::RelsExtDatastream, :label=>"Fedora Object-to-Object Relationship Metadata", :control_group=>'X', :block=>nil}}

  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :label=>"Rights metadata", :type => RightsMetadata 
  
  has_metadata :name => "descMetadata", :label=>"MODS metadata", :type => Hydra::ModsJournalArticle, :control_group=>'M'

  has_metadata :name => "contentMetadata", :label=>"Content metadata", :type => ContentMetadata, :control_group=>'M'

  has_metadata :name => "DC", :label=>"DC admin metadata", :type => ObjectDc

  has_workflow_validation :deleted do
    validates_presence_of ("descMetadata",[:admin_note])
    is_valid?
  end

  has_workflow_validation :hidden do
    validates_presence_of ("descMetadata",[:admin_note])
    is_valid?
  end

 # A place to put extra metadata values
  has_metadata :name => "properties", :label=>"Workflow properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'collection', :string
    m.field 'depositorEmail', :string  
    m.field 'depositor', :string
  end

end
