module ContributorsHelper
  
  NO_EDIT_CONTENT_TYPES = ['journal_article']

  def editable?(content_type)
    !NO_EDIT_CONTENT_TYPES.include?(content_type)
  end

  def extract_name_value(hash)
    begin
      return hash.invert.keys.first.invert.keys.first
    rescue
      nil
    end
  end

  def extract_role_value(hash)
    begin
      return hash.invert.keys.last.invert.keys.first
    rescue
      return nil
    end
  end
end
