require 'spec_helper'
require 'user_helper'

# See cucumber tests (ie. /features/edit_document.feature) for more tests, including ones that test the edit method & view
# You can run the cucumber tests with 
#
# cucumber --tags @edit
# or
# rake cucumber

describe LicencesController do 

  describe "new" do 
    include UserHelper
    it "should check permissions" do
      controller.expects(:enforce_create_permissions)
      get :new
    end

  end

end
