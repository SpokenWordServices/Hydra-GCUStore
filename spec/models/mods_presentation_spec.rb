require 'spec_helper'

describe ModsPresentation do

  describe "from xml" do
    before do
      @instance = ModsPresentation.from_xml(
        '<mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
            <titleInfo>
              <title>A Grand Presentation Title</title>
            </titleInfo>
            <originInfo>
              <dateIssued>1999-01-05</Issued>
              <dateValid encoding="iso8601">2000-11-30</dateValid>
            </originInfo>
            <relatedItem type="relatedMaterials">
              <location>
                <url access="object in context" usage="primary display">http://example.com</url>
              </location>
            </relatedItem>
        </mods>'
      )
    end

    it "Should have terms" do
      @instance.date_valid.should == ["2000-11-30"]
      @instance.origin_info.date_issued.should == ["1999-01-05"]
      @instance.related_web_materials.location.primary_display.should == ["http://example.com"]
      @instance.web_related_item.location.primary_display.should == ["http://example.com"]
      @instance.title.should == ["A Grand Presentation Title"]
    end
    it "Should have a title facet" do
      @instance.to_solr["title_facet"].should == ["A Grand Presentation Title"]
    end
  end

end

