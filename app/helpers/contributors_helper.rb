module ContributorsHelper
  
  NO_EDIT_CONTENT_TYPES = ['journal_article']

  def editable?(content_type)
    !NO_EDIT_CONTENT_TYPES.include?(content_type)
  end

  # retrieves the name from the hash returned by params[:asset][:descMetadata] hash when creating a contributor
  #
  # @param [Hash] hash Params hash: params[:asset][:descMetadata]
  # @return [String] name of contributor
  def extract_name_value(hash)
    extract_nested_hash_value(hash, "namePart")
  end

  # retrieves the role from the hash returned by params[:asset][:descMetadata] hash when creating a contributor
  #
  # @param [Hash] hash Params hash: params[:asset][:descMetadata]
  # @return [String] role of contributor
  def extract_role_value(hash)
    extract_nested_hash_value(hash, "role_text")
  end

  # retrieves the role from the hash returned by params[:asset][:descMetadata] hash when creating a contributor
  #
  # @param [Hash] hash Params hash: normally this would be params[:asset][:descMetadata]
  # @param [String] matcher The last part of the indexed field to match on (e.g "role_text" or "namePart")
  # @return [String] role of contributor
  def extract_nested_hash_value(hash, matcher)
    key = nil
    hash.keys.each {|k| key = k if k =~ /^(organization|person)_\d+_#{matcher}$/ }
    return hash[key].invert.keys.first if key
    nil
  end
end
