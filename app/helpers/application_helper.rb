module ApplicationHelper
  include Stanford::SearchworksHelper
  #include Stanford::SolrHelper # this is already included by the SearchworksHelper
  include SaltHelper
  
  def application_name
    'SALT (Self Archiving Legacy Toolkit)'
  end
  
  def edit_and_browse_links
    result = ""
    if params[:action] == "edit"
      result << "<a href=\"#{catalog_path(@document[:id])}\" class=\"browse\">Browse</a>"
      result << "<a href=\"#\" class=\"edit active\">Edit</a>"
    else
      result << "<a href=\"#\" class=\"browse active\">Browse</a>"
      result << "<a href=\"#{edit_catalog_path(@document[:id])}\" class=\"edit\">Edit</a>"
    end
    # result << link_to "Browse", "#", :class=>"browse"
    # result << link_to "Edit", edit_document_path(@document[:id]), :class=>"edit"
    return result
  end
end