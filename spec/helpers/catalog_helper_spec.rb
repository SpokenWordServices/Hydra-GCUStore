require 'spec_helper'

describe CatalogHelper do
  include CatalogHelper

  describe "Display datatastream field content" do
    it "should generate valid html for one returned value" do
      generated_html = helper.display_datastream_field(@resource, "simple_ds",["first_name"],"FIRST","first_name")
      generated_html.should be_html_safe
      generated_html.should have_selector 'dt', :text=> "FIRST"
      generated_html.should have_selector 'dd.first_name', :text=> "Bob"
    end
    it "should generate valid html for multiple returned values" do
      generated_html = helper.display_datastream_field(@resource, "simple_ds",["role"],"Role","role")
      generated_html.should have_selector 'dt', :text=> "Roles"
      generated_html.should have_selector 'dd.role', :text=> "creator; depositor"
    end
    it "should generate an empty string for no returned values" do
      generated_html = helper.display_datastream_field(@resource, "simple_ds",["status"],"Status","enrollment_status")
      generated_html.should be_blank
    end
  end

  describe "breadcrumb_trail_for_set" do

    it "should be html safe" do
      generated_html = helper.breadcrumb_trail_for_set('hull:3374')
      generated_html.should be_html_safe
    end
  end

  describe "get_persons_from_roles" do
    it "should get them" do
      doc ={"person_1_namePart_t"=>["Awre, Christopher L."],  "person_0_namePart_t"=>["Green, Richard A."], "person_0_role_t"=>["creator"], "person_1_role_t"=>["creator"] }
      helper.get_persons_from_roles(doc,['creator']).should ==  [{:affiliation=>nil,
         :person_index=>"0",
         :role=>["creator"],
         :name=>["Green, Richard A."]},
        {:affiliation=>nil,
         :person_index=>"1",
         :role=>["creator"],
         :name=>["Awre, Christopher L."]}]

    end
  end
end

def get_values_from_datastream(doc,ds,fields)
  case fields[0]
  when "first_name"
    return ["Bob"]
  when "role"
    return ["creator","depositor"]
  else
    return [""]
  end
end

def fedora_field_label(ds,fields,label)
  label
end
