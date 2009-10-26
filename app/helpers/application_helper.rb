module ApplicationHelper
  include Stanford::SearchworksHelper
  #include Stanford::SolrHelper # this is already included by the SearchworksHelper
  include SaltHelper
  
  def application_name
    'SALT (Self Archiving Legacy Toolkit)'
  end
end