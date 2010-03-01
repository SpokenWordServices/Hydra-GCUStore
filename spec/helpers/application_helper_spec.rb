require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do
  include ApplicationHelper
  describe "Overridden blacklight methods" do
    describe "link_to_document" do
      before(:each)do
        @mock_doc = mock('mock doc')
        @mock_doc.expects(:[]).with(:id).returns("123456")
      end
      it "passes on the title attribute to the link_to_with_data method" do
        link_to_document(@mock_doc,:label=>"Some crazy long label...",:title=>"Some crazy longer label").should match(/title=\"Some crazy longer label\"/)
      end
      it "doesn't add an erroneous title attribute if one isn't provided" do
        link_to_document(@mock_doc,:label=>"Some crazy long label...").should_not match(/title=/)
      end
    end
  end
end