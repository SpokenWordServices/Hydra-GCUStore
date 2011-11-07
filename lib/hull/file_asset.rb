class FileAsset < ActiveFedora::Base
  #require_dependency 'vendor/plugins/hydra_repository/app/models/file_asset.rb'

  # Overriding the to_solr method for hull's file asset objects in order to ensure that
  # the parent object gets solrized when a pdf is present
  def to_solr(solr_doc = Hash.new, opts={})

    active_fedora_model_s = solr_doc["active_fedora_model_s"] if solr_doc["active_fedora_model_s"]
    actual_class = active_fedora_model_s.constantize if active_fedora_model_s
    if actual_class && actual_class != self.class && actual_class.superclass == FileAsset
      solr_doc
    else
      super(solr_doc,opts)
    end
    
    solrize_parent
    
    solr_doc
  end

  def solrize_parent
    if datastreams.keys.include?("content") && datastreams['content'].mime_type == 'application/pdf'
      s = Solrizer::Fedora::Solrizer.new
      parents = part_of
      parents.each do |parent|
        puts "Solrizing parent object: #{parent.pid}"
        s.solrize parent
      end
    end
  end

end
