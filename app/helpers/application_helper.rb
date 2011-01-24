require 'vendor/plugins/blacklight/app/helpers/application_helper.rb'
require 'vendor/plugins/hydra_repository/app/helpers/application_helper.rb'
module ApplicationHelper
  
# For some reason, this file seems to need to exists in order for rspec to work. 
# If not, the ApplicationHelper from hydra_repository is not loaded  and (therefore) the Blacklight
# ApplicationHelper is not overridden. 

  # Change the name of your application here
  def application_name
    'Hydrangea'
  end
  
end
