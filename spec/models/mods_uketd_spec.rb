require 'spec_helper'

describe ModsUketd do

  describe "from xml" do
    before do
      @instance = ModsUketd.from_xml(
        '<mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
            <titleInfo>
              <title>A Grand Mods Title</title>
            </titleInfo>
            <originInfo>
              <dateIssued encoding="iso8601">2000-11-30</dateIssued>
            </originInfo>
        </mods>'
      )
    end

    it "Should have a title term" do
      @instance.title.should == ["A Grand Mods Title"]
    end
    it "Should have a title facet" do
      @instance.to_solr["title_facet"].should == ["A Grand Mods Title"]
    end
  end

end

