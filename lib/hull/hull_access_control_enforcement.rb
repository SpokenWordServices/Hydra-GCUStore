module HullAccessControlEnforcement

	def enforce_create_permissions 
		if has_create_permissions == false
			session[:viewing_context] = "browse"
			flash[:notice] = "You do not have sufficient privileges to create resources. You have been redirected to the Home page."
		  redirect_to :controller => "catalog", :action => "index"
		end
	end

	def has_create_permissions
		create = false
		if !(current_user == nil) 
			#RoleMapper.roles(current_user.login).each { |user_group| GROUP_PERMISSIONS["create_resources"].include? user_group { create = true } }
			RoleMapper.roles(current_user.login).each do |user_group|
					if GROUP_PERMISSIONS["create_resources"].include? user_group
						create = true
					end
			end
 		end
		create
	end		  
end

