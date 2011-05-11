module ContributorsHelper
  
  NO_EDIT_CONTENT_TYPES = ['journal_article']

  def editable?(content_type)
    !NO_EDIT_CONTENT_TYPES.include?(content_type)
  end

end
