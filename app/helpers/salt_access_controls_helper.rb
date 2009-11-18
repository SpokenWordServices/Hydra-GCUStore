module SaltAccessControlsHelper
  
  def editor?
    user = session[:user]
    RoleMapper.roles(user).include?("donor") || RoleMapper.roles(user).include?("archivist")
  end
  
end