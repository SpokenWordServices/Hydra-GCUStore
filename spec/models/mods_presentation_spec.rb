require 'spec_helper'

describe ModsPresentation do

  describe "from xml" do
    before do
      @instance = ModsPresentation.from_xml(
        '<mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
            <originInfo>
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

    it "Should have a root term for dateValid" do
      @instance.date_valid.should == ["2000-11-30"]
    end
    it "Should have a root term for related_web_materials and a ref to it called web_related_item" do
      @instance.related_web_materials.location.primary_display.should == ["http://example.com"]
      @instance.web_related_item.location.primary_display.should == ["http://example.com"]
    end
  end

end

