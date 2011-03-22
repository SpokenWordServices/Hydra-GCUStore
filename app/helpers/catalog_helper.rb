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

  def get_organizations_from_roles(doc,roles,opts={})
    i = 0
    orgs = []
    while i < 10
      orgs_roles = []
      orgs_roles = doc["organization_#{i}_role_t"].map{|w|w.strip.downcase} unless doc["organization_#{i}_role_t"].nil?
      if orgs_roles and (orgs_roles & roles).length > 0
        orgs << {:name => doc["organization_#{i}_namePart_t"],:role => doc["organization_#{i}_role_t"]}
      end
      i += 1
    end
    return orgs
  end 

	def display_datastream_field(document,datastream_name,fields=[],label_text='',dd_class=nil)
    dd_class = "class=\"#{dd_class}\"" if dd_class
    datastream_field = ""
	 	unless get_values_from_datastream(document,datastream_name, fields).first.empty?
      datastream_field = <<-EOS
        <dt>
          #{fedora_field_label(datastream_name,fields,label_text)}:
        </dt>
        <dd #{dd_class}>
            #{get_values_from_datastream(document,datastream_name, fields).join("; ")}
        </dd>
      EOS
    end
    datastream_field
  end

end

