require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include SaltHelper


describe SaltHelper do
  
  describe "link_to_multifacet" do
    #"box_facet"=>["7"]
    it "should create a link to a catalog search with the desired facets" do
      CGI.unescape(link_to_multifacet("my link", "series_facet" => "7", "box_facet" => ["41"])).should == "<a href=\"/catalog?f[box_facet][]=41&amp;f[series_facet][]=7\">my link</a>"
    end
  end
  
  describe "get_html_data_with_label" do
    it "should return unescaped html from story_display field" do
     
     sample_document = {'story_display' => [" &lt;p&gt;Hello&lt;/p&gt;&lt;ol&gt;
        &lt;li&gt;1&lt;/li&gt;
        &lt;li&gt;2&lt;/li&gt;

        &lt;li&gt;3&lt;/li&gt;
        &lt;li&gt;
          &lt;em&gt;strong&lt;/em&gt;
        &lt;/li&gt;
      &lt;/ol&gt;"]}
      
     get_html_data_with_label(sample_document,"Stories:", 'story_display').should == "<dt>Stories:</dt><dd> <p>Hello</p><ol>\n        <li>1</li>\n        <li>2</li>\n\n        <li>3</li>\n        <li>\n          <em>strong</em>\n        </li>\n      </ol><br/></dd>"
      
    end
  end
  
end