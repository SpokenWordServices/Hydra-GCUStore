require 'yaml'
class RoleMapper
  class << self
    def role_names
	Role.all.map { |role| role.name }
    end

    def roles(username)
     if !User.find_by_username(username).nil?
      User.find_by_username(username).roles.map { |role| role.name }
     else
      []	
     end
    end
    
    def whois(r)
      if !Role.find_by_name(r).nil?
       Role.find_by_name(r).users.map { |user| user.username }
      else
       []
      end
    end    
  end
end
