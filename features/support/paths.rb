module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in webrat_steps.rb
  #
  def path_to(page_name, user_id=nil)
    
    if user_id
      case page_name
      when /the edit document page for (.*)$/i
        edit_catalog_path($1, :wau=>user_id)
      when /the show document page for (.*)$/i
        catalog_path($1, :wau=>user_id) 
      end    
      
    else
    
      case page_name
    
      when /the home\s?page/
        '/'
      when /the search page/
        '/'
      # Add more mappings here.
      # Here is a more fancy example:
      #
      #   when /^(.*)'s profile page$/i
      #     user_profile_path(User.find_by_login($1))

      when /the edit document page for (.*)$/i
        edit_catalog_path($1)
      when /the show document page for (.*)$/i
        catalog_path($1)
      else
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
