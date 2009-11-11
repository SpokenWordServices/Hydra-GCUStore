require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include SaltHelper


describe SaltHelper do
  
  before(:all) do
    @descriptor = Descriptor.retrieve("sc0340")
  end
  
  describe "link_to_multifacet" do
    #"box_facet"=>["7"]
    it "should create a link to a catalog search with the desired facets" do
      CGI.unescape(link_to_multifacet("my link", "series_facet" => "7", "box_facet" => ["41"])).should == "<a href=\"/catalog?f[box_facet][]=41&amp;f[series_facet][]=7\">my link</a>"
    end
  end
  
  describe "ead_title" do
    it "should read the title from the ead description" do
      ead_title.should == "Edward A. Feigenbaum Papers"
    end
  end
  
  describe "ead_folder_title" do
    it "should return the title for the given series, box and folder, appending folder number to the title" do
      ead_folder_title("Accession 1986-052>", "Box 51", "Folder 12", @descriptor).should == "12: Pylyshyn, Zenon W."
    end
    it "should work with eaf7000 as series name" do
      ead_folder_title("eaf7000", "Box 20", "Folder 57", @descriptor).should == "57: SRI Papers of W. F. Miller"
    end
    it "should work with box and folder numbers" do
      ead_folder_title("Accession 2005-101>", "74", "11", @descriptor).should == "11: Feigenbaum, MacNeil -Lehrer Report, \"Artificial Intelligence\"1987"
      ead_folder_title("Accession 2005-101>", 46, 7, @descriptor).should == "7: \"Human Processing of Knowledge from Texts: Acquisition, Integration, and Reasoning\" by P.W. Thorndyke and B. Hayes-Roth1979"
    end
    it "should work with folders that include the folder id and title already" do
      ead_folder_title("Accession 2005-101>", "74", "11: Feigenbaum, MacNeil -Lehrer Report, \"Artificial Intelligence\" 1987", @descriptor).should == "11: Feigenbaum, MacNeil -Lehrer Report, \"Artificial Intelligence\" 1987"
    end
  end
  
end