require 'mediashelf/active_fedora_helper'

class AssetsController < ApplicationController
		include HullAccessControlEnforcement

		before_filter :enforce_permissions, :only =>:new

		protected
			def enforce_permissions
				enforce_create_permissions
			end
      
end
