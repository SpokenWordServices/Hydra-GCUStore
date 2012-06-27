module BlacklightHelper
  include Hydra::BlacklightHelperBehavior

# Display more user friendly info for Display Set facets (Collections)
  def render_facet_value(solr_field, item, options={})
    if solr_field == 'is_member_of_s'
      alternate =DisplaySet.name_of_set(item.value.partition("/")[2])
      alternate = nil if alternate == "Root Set"
      render_facet_alternate_value(solr_field, item, alternate) if alternate
    else
      super
    end
  end

  def render_selected_facet_value(facet_solr_field, item)
    if facet_solr_field == 'is_member_of_s'
      alternate =DisplaySet.name_of_set(item.value.partition("/")[2])
      alternate = nil if alternate == "Root Set"
      render_selected_facet_alternate_value(facet_solr_field, item, alternate) if alternate
    else
      super
    end
  end

  def render_facet_alternate_value(facet_solr_field, item, alternate, options={})    
      if item.is_a? Array
        link_to_unless(options[:suppress_link], alternate, add_facet_params_and_redirect(facet_solr_field, item[0]), :class=>"facet_select") + " (" + format_num(item[1]) + ")" 
      else
        link_to_unless(options[:suppress_link], alternate, add_facet_params_and_redirect(facet_solr_field, item.value), :class=>"facet_select") + " (" + format_num(item.hits) + ")" 
      end 
  end 

  def render_selected_facet_alternate_value(facet_solr_field, item, alternate)    
    content_tag(:span, render_facet_alternate_value(facet_solr_field, item, alternate, :suppress_link => true), :class => "selected")
  end




  def catalog_path(*args)
    resource_path(*args)
  end
  def edit_catalog_path(*args)
    edit_resource_path(*args)
  end
end
