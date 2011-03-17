module CatalogHelper

  require_dependency "vendor/plugins/hydra_repository/app/helpers/catalog_helper.rb"


  def get_persons_from_roles(doc,roles,opts={})
    i = 0
    persons =[]
    while i < 10
      persons_roles = [] # reset the array
      persons_roles = doc["person_#{i}_role_t"].map{|w|w.strip.downcase} unless doc["person_#{i}_role_t"].nil?
      if persons_roles and (persons_roles & roles).length > 0
        persons << {:name => doc["person_#{i}_namePart_t"],:role => doc["person_#{i}_role_t"]}
      end
      i += 1
    end
    return persons
  end 
end

