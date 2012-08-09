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

end

