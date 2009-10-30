require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include SaltHelper


describe SaltHelper do
  
  describe "link_to_multifacet" do
    #"box_facet"=>["7"]
    it "should create a link to a catalog search with the desired facets" do
      CGI.unescape(link_to_multifacet("my link", "series_facet" => "7", "box_facet" => ["41"])).should == "<a href=\"/catalog?f[box_facet][]=41&amp;f[series_facet][]=7\">my link</a>"
    end
  end
  
  describe "ead_title" do
    it "should read the title from the ead description" do
      @descriptor = Descriptor.retrieve("sc0340")
      ead_title.should == "Edward A. Feigenbaum Papers"
    end
  end
  
end