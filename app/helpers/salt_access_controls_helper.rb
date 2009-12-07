module SaltAccessControlsHelper
  
  def editor?
    user = session[:user]
    RoleMapper.roles(user).include?("donor") || RoleMapper.roles(user).include?("archivist")
  end
  
  def reader?
    user = session[:user]
    RoleMapper.roles(user).include?("donor") || RoleMapper.roles(user).include?("archivist") || RoleMapper.roles(user).include?("researcher") || RoleMapper.roles(user).include?("patron")
  end
  
end