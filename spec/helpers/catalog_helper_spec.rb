require 'spec_helper'

describe CatalogHelper do
  include CatalogHelper
  include HydraFedoraMetadataHelper

  describe "Display datatastream field content" do
    it "should generate valid html for one returned value" do
      helper.expects(:get_values_from_datastream).returns(["Bob"]).times(3)
      generated_html = helper.display_datastream_field(@resource, "simple_ds",["first_name"],"FIRST","first_name")
      generated_html.should be_html_safe
      generated_html.should have_selector 'dt', :text=> "FIRST"
      generated_html.should have_selector 'dd.first_name', :text=> "Bob"
    end
    it "should generate valid html for multiple returned values" do
      helper.expects(:get_values_from_datastream).returns(["creator","depositor"]).times(3)
      generated_html = helper.display_datastream_field(@resource, "simple_ds",["role"],"Role","role")
      generated_html.should have_selector 'dt', :text=> "Roles"
      generated_html.should have_selector 'dd.role', :text=> "creator; depositor"
    end
    it "should generate an empty string for no returned values" do
      helper.expects(:get_values_from_datastream).returns([""])
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

  describe "fedora_content_url" do 
    it "should return the media path" do 
      helper.fedora_content_url("gcu:foo","bar").should == "http://test.host/assets/gcu:foo/media/bar"
    end
  end

  describe "get_video_display_resolution" do 
    it " should default to widescreen if ContentMetadata missing" do
      @resource=GenericVideo.new
      @resource.expects(:datastreams).returns({})
      helper.get_video_display_resolution(@resource,"contentMetadata","content").should == {:height=>"288", :width=>"512"} 
    end
    it " should default to widescreen if videoData missing" do
      @resource=GenericVideo.new
      @datastream.expects(:kind_of?).returns(true)
      @datastream.expects(:find_by_xpath).returns("").times(2)
      @resource.expects(:datastreams).returns({"contentMetadata"=>@datastream})
      helper.get_video_display_resolution(@resource,"contentMetadata","content").should == {:height=>"288", :width=>"512"} 
    end
    it " should scale widescreen display to within maximum size" do
      @resource=GenericVideo.new
      @datastream.expects(:kind_of?).returns(true)
      @datastream.expects(:find_by_xpath).with("//xmlns:resource[@dsID='content']/xmlns:file/xmlns:videoData/@width").returns("1280")
      @datastream.expects(:find_by_xpath).with("//xmlns:resource[@dsID='content']/xmlns:file/xmlns:videoData/@height").returns("720")
      @resource.expects(:datastreams).returns({"contentMetadata"=>@datastream})
      helper.get_video_display_resolution(@resource,"contentMetadata","content").should == {:height=>"288", :width=>"512"} 
    end
    it " should scale 4:3 display to within maximum size" do
      @resource=GenericVideo.new
      @datastream.expects(:kind_of?).returns(true)
      @datastream.expects(:find_by_xpath).with("//xmlns:resource[@dsID='content']/xmlns:file/xmlns:videoData/@width").returns("768")
      @datastream.expects(:find_by_xpath).with("//xmlns:resource[@dsID='content']/xmlns:file/xmlns:videoData/@height").returns("576")
      @resource.expects(:datastreams).returns({"contentMetadata"=>@datastream})
      helper.get_video_display_resolution(@resource,"contentMetadata","content").should == {:height=>"288", :width=>"384"} 
    end
    it " should scale non-standard display to within maximum size" do
      @resource=GenericVideo.new
      @datastream.expects(:kind_of?).returns(true)
      @datastream.expects(:find_by_xpath).with("//xmlns:resource[@dsID='content']/xmlns:file/xmlns:videoData/@width").returns("840")
      @datastream.expects(:find_by_xpath).with("//xmlns:resource[@dsID='content']/xmlns:file/xmlns:videoData/@height").returns("524")
      @resource.expects(:datastreams).returns({"contentMetadata"=>@datastream})
      helper.get_video_display_resolution(@resource,"contentMetadata","content").should == {:height=>"320", :width=>"512"} 
    end
  end

end

# def get_values_from_datastream(doc,ds,fields)
#   case fields[0]
#   when "first_name"
#     return ["Bob"]
#   when "role"
#     return ["creator","depositor"]
#   else
#     return [""]
#   end
# end
# 
def fedora_field_label(ds,fields,label)
  label
end
