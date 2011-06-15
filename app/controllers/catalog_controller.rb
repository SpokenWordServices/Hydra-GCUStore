require 'mediashelf/active_fedora_helper'
class CatalogController
  
 include HullAccessControlEnforcement
  
 before_filter :enforce_permissions, :only=>[:create] 
 
	protected
		def enforce_permissions
			enforce_create_permissions
		end
end
