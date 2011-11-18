autoload :FileAssetExtra, 'hull/file_asset_extra'
autoload :FileAssetsControllerExtra, 'hull/file_assets_controller_extra'
autoload :HullAccessControlEnforcement, 'hull/hull_access_control_enforcement'
autoload :HullModelMethods, 'hull/hull_model_methods'
autoload :HullValidationMethods, 'hull/hull_validation_methods'
	  	
### These files are in lib, but aren't being loaded yet. Do we need them?  Justin - 2011-11-10
#lib/hull/block_mapper.rb
#lib/hull/ead_mapper.rb
#lib/hull/field_maps.rb
#lib/hull/jetty_cleaner.rb
#lib/hull/marc_mapper.rb
#lib/hull/marc_record_ext.rb
#lib/hull/prev_next_links.rb
#lib/hull/stomp_listener.rb
#lib/hull/user_attributes_loader.rb
   
module Hull
   extend ActiveSupport::Autoload
   autoload :AssetsControllerHelper
   autoload :Iso8601
end


