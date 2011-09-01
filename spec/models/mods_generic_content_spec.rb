require 'spec_helper'

describe ModsGenericContent do

  describe "from xml" do
    before do
      @instance = ModsGenericContent.from_xml(
        '<mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
            <originInfo>
              <dateValid encoding="iso8601">2000-11-30</dateValid>
            </originInfo>'
      )
    end

    it "Should have a root term for dateValid" do
      @instance.date_valid.should == ["2000-11-30"]
    end
  end

end
