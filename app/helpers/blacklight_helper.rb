module BlacklightHelper
  include Hydra::BlacklightHelperBehavior

  def render_facet_value(solr_field, item)
    if solr_field == 'top_level_collection_id_s'
		  link_to "Collections", "/?f%5Bis_member_of_s%5D%5B%5D=info:fedora/hull:rootDisplaySet&results_view=true" 
    else
      super
    end
  end


  def catalog_path(*args)
    resource_path(*args)
  end
  def edit_catalog_path(*args)
    edit_resource_path(*args)
  end
end
