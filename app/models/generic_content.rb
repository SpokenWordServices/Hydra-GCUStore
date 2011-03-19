class GenericContent < ActiveFedora::Base
  require_dependency 'vendor/plugins/hydra_repository/app/models/generic_content.rb'

  has_metadata :name => "DC", :type => ActiveFedora::NokogiriDatastream

end
