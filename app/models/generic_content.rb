class GenericContent < ActiveFedora::Base
  require_dependency 'vendor/plugins/hydra_repository/app/models/generic_content.rb'

  has_metadata :name => "DC", :type => ActiveFedora::NokogiriDatastream


  def to_solr(solr_doc=Hash.new,opts={})
    super(solr_doc,opts)
    solr_doc << {"has_model_s" => "GenericContent"}
    solr_doc
  end
end
