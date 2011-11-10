autoload :FileAssetExtra, 'hull/file_asset_extra'
autoload :FileAssetsControllerExtra, 'hull/file_assets_controller_extra'
autoload :HullAccessControlEnforcement, 'hull/hull_access_control_enforcement'
autoload :HullModelMethods, 'hull/hull_model_methods'
autoload :HullValidationMethods, 'hull/hull_validation_methods'
autoload :CatalogHelperExtra, 'hull/catalog_helper_extra'
   
module Hull
   extend ActiveSupport::Autoload
   autoload :AssetsControllerHelper
   autoload :Iso8601
end


