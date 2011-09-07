require 'spec_helper'

describe ModsMeetingPaper do

  describe "from xml" do
    before do
      @instance = ModsMeetingPaper.from_xml(
        '<mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
            <titleInfo>
              <title>A Grand Meeting Title</title>
            </titleInfo>
            <originInfo>
              <dateIssued>1999-01-05</Issued>
            </originInfo>
        </mods>'
      )
    end

    it "Should have terms" do
      @instance.origin_info.date_issued.should == ["1999-01-05"]
      @instance.title.should == ["A Grand Meeting Title"]
    end
    it "Should have a title facet" do
      @instance.to_solr["title_facet"].should == ["A Grand Meeting Title"]
    end
  end

end


