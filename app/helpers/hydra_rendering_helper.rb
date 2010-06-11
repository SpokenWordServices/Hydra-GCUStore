module HydraRenderingHelper

  def document_type(document)
    document[Blacklight.config[:show][:display_type]].first.gsub("info:fedora/afmodel:","")
  end

  # currently only used by the render_document_partial helper method (below)
  def document_partial_name(document)
    if !document[Blacklight.config[:show][:display_type]].nil?
      return document[Blacklight.config[:show][:display_type]].first.gsub("info:fedora/afmodel:","").underscore.pluralize
    else
      return nil
    end
  end
  
  # Overriding Blacklight's render_document_partial
  # given a doc and action_name, this method attempts to render a partial template
  # based on the value of doc[:format]
  # if this value is blank (nil/empty) the "default" is used
  # if the partial is not found, the "default" partial is rendered instead
  def render_document_partial(doc, action_name, locals={})
    format = document_partial_name(doc)
    begin
      Rails.logger.debug("attempting to render #{format}/_#{action_name}")
      render :partial=>"#{format}/#{action_name}", :locals=>{:document=>doc}.merge(locals)
    rescue ActionView::MissingTemplate
      Rails.logger.debug("rendering default partial catalog/_#{action_name}_partials/default")
      render :partial=>"catalog/_#{action_name}_partials/default", :locals=>{:document=>doc}.merge(locals)
    end
  end
  
end
