require 'spec_helper'

describe CatalogHelper do
  include CatalogHelper

  describe "Display datatastream field content" do
    it "should generate valid html for one returned value" do
      generated_html = helper.display_datastream_field(@resource, "simple_ds",["first_name"],"FIRST","first_name")
      generated_html.should have_tag 'dt', "FIRST"
      generated_html.should have_tag 'dd.first_name', "Bob"
    end
    it "should generate valid html for multiple returned values" do
      generated_html = helper.display_datastream_field(@resource, "simple_ds",["role"],"Role","role")
      generated_html.should have_tag 'dt', "Roles"
      generated_html.should have_tag 'dd.role', "creator; depositor"
    end
    it "should generate an empty string for no returned values" do
      generated_html = helper.display_datastream_field(@resource, "simple_ds",["status"],"Status","enrollment_status")
      generated_html.should be_blank
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
