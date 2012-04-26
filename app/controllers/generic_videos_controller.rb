class GenericAudiosController < ApplicationController
  
  include MediaShelf::ActiveFedoraHelper
  include Hull::AssetsControllerHelper
  include HullAccessControlEnforcement
  
  before_filter :enforce_access_controls
  before_filter :require_solr

end
