module HullAccessControlEnforcement

	def enforce_create_permissions 
		if has_create_permissions == false
			session[:viewing_context] = "browse"
			flash[:notice] = "You do not have sufficient privileges to create resources. You have been redirected to the Home page."
		  redirect_to root_path
		end
	end

	def has_create_permissions
		if current_user
			RoleMapper.roles(current_user.username).each do |user_group|
					if GROUP_PERMISSIONS["create_resources"].include? user_group
						return true
					end
			end
 		end
		false
	end		  

  # Redefine enforce_show_permissions as the hydra-head version seems to wrongly allow public through when should only be discovering not reading
  def enforce_show_permissions(opts={})
    load_permissions_from_solr
#    unless @permissions_solr_document['access_t'] && (@permissions_solr_document['access_t'].first == "public" || @permissions_solr_document['access_t'].first == "Public")
    unless @permissions_solr_document['access_t'] && (@permissions_solr_document['access_t'][1] =~ /\b(?i)public\b/ )
      if @permissions_solr_document["embargo_release_date_dt"] 
        embargo_date = Date.parse(@permissions_solr_document["embargo_release_date_dt"].split(/T/)[0])
        if embargo_date > Date.parse(Time.now.to_s)
          # check for depositor raise "#{@document["depositor_t"].first} --- #{user_key}"
          ### Assuming we're using devise and have only one authentication key
          unless current_user && user_key == @permissions_solr_document["depositor_t"].first
            flash[:notice] = "This item is under embargo.  You do not have sufficient access privileges to read this document."
            redirect_to(:action=>'index', :q=>nil, :f=>nil) and return false
          end
        end
      end
      unless reader?
        flash[:notice]= "You do not have sufficient access privileges to read this document, which has been marked private."
        redirect_to(:action => 'index', :q => nil , :f => nil) and return false
      end
    end
  end


end

