class FileAsset < ActiveFedora::Base
  include Hydra::Models::FileAsset
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 
end
