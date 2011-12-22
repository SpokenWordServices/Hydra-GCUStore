class FileAsset < ActiveFedora::Base
  include Hydra::Models::FileAsset

	#We want the RELS-EXT to be X and have label
  self.ds_specs = {'RELS-EXT'=> {:type=> ActiveFedora::RelsExtDatastream, :label=>"Fedora Object-to-Object Relationship Metadata", :control_group=>'X', :block=>nil}}

  has_metadata :name => "descMetadata", :type => ActiveFedora::QualifiedDublinCoreDatastream
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 


  #Overridden so that we can store a cmodel and commonMetadata
  def assert_content_model
		add_relationship(:has_model, "info:fedora/afmodel:fileAsset")
    add_relationship(:has_model, "info:fedora/hydra-cModel:commonMetadata")
  end
end
