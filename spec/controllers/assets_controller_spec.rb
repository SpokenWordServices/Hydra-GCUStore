require 'spec_helper'


# See cucumber tests (ie. /features/edit_document.feature) for more tests, including ones that test the edit method & view
# You can run the cucumber tests with 
#
# cucumber --tags @edit
# or
# rake cucumber

describe AssetsController do
  
  before do
    request.env['WEBAUTH_USER']='bob'
  end
  
  it "should use DocumentController" do
    controller.should be_an_instance_of(AssetsController)
  end

  describe "#update_set_membership" do
    before do
      @ss = StructuralSet.find('hull:3374')
      @ss.defaultObjectRights.edit_access.machine.group= 'researcher'
      @ss.save
    end
    describe "with a non-structural set" do

      it "Should update the relationships for a non-Structural Set" do
        @document = ExamPaper.new
        controller = AssetsController.new
        controller.instance_variable_set :@document, @document
        controller.params = {'Structural Set' => "info:fedora/hull:3374" }
        
        controller.send :update_set_membership
        @document.relationships(:is_member_of).should == ["info:fedora/hull:protoQueue","info:fedora/hull:3374"]
        @document.relationships(:is_governed_by).should == ["info:fedora/hull:3374"]
        @document.rightsMetadata.edit_access.machine.group.should == ['researcher']

        controller.params = {'Structural Set' => "info:fedora/hull:3374", 'Display Set' => 'info:fedora/hull:9' }
        controller.send :update_set_membership
        @document.relationships(:is_member_of).should include("info:fedora/hull:protoQueue","info:fedora/hull:3374", "info:fedora/hull:9")
        @document.relationships(:is_governed_by).should == ["info:fedora/hull:3374"]

        controller.params = {'Display Set' => ['info:fedora/hull:9'] }
        controller.send :update_set_membership
        @document.relationships(:is_member_of).should == ["info:fedora/hull:protoQueue","info:fedora/hull:9"]
        @document.relationships(:is_governed_by).should == ["info:fedora/hull:3374"]

        ### Deleting
        controller.params = {'Display Set' => [''], 'Structural Set' => [""] }
        controller.send :update_set_membership
        @document.relationships(:is_member_of).should == ["info:fedora/hull:protoQueue"]
        @document.relationships(:is_governed_by).should == ["info:fedora/hull:protoQueue"]

      end
    end
    it "Should update the relationships for a Structural Set" do
      @document = StructuralSet.new
      controller = AssetsController.new
      controller.instance_variable_set :@document, @document
      controller.params = {'Structural Set' => "info:fedora/hull:3374" }
      
      controller.send :update_set_membership
      @document.relationships(:is_member_of).should == ["info:fedora/hull:3374"]
      @document.relationships(:is_governed_by).should == ["info:fedora/hull-apo:structuralSet"]
      ## rightsMetadata should be a clone of hull-apo:structuralSet
      @document.rightsMetadata.edit_access.machine.group.should == ['contentAccessTeam']
      ## defaultObjectRights should be a clone of hull:3374(which was updated in the begin block)
      @document.defaultObjectRights.edit_access.machine.group.should == ['researcher']

      controller.params = {'Structural Set' => "info:fedora/hull:3374", 'Display Set' => 'info:fedora/hull:9' }
      controller.send :update_set_membership
      @document.relationships(:is_member_of).should include("info:fedora/hull:3374", "info:fedora/hull:9")
      @document.relationships(:is_governed_by).should == ["info:fedora/hull-apo:structuralSet"]
      @document.rightsMetadata.edit_access.machine.group.should == ['contentAccessTeam']

      controller.params = {'Display Set' => ['info:fedora/hull:9'] }
      controller.send :update_set_membership
      @document.relationships(:is_member_of).should == ["info:fedora/hull:9"]
      @document.relationships(:is_governed_by).should == ["info:fedora/hull-apo:structuralSet"]
      @document.rightsMetadata.edit_access.machine.group.should == ['contentAccessTeam']

      ### Deleting
      controller.params = {'Display Set' => [''] }
      controller.send :update_set_membership
      @document.relationships(:is_member_of).should be_empty
      @document.relationships(:is_governed_by).should == ["info:fedora/hull-apo:structuralSet"]
      @document.rightsMetadata.edit_access.machine.group.should == ['contentAccessTeam']

    end

    after do
      @ss.defaultObjectRights.edit_access.machine.group= 'contentAccessTeam'
      @ss.defaultObjectRights.save
    end


  end
  
  describe "update" do
    
    it "should load the appropriate filters" do
      expected_filters = [:search_session, :history_session, :sanitize_update_params, :require_solr, :check_embargo_date_format, :enforce_permissions, :update_set_membership, :validate_parameters]
      filters = AssetsController._process_action_callbacks.map(&:filter)
      expected_filters.each do |filter|
        filters.should include filter 
      end
    end
    
    it "should call custom hull filters" do
      mock_document = mock("document")
      mock_document.stubs(:update_from_computing_id).returns(nil)
      mock_document.stubs(:respond_to?).with(:apply_governed_by).returns(true)
      controller.expects(:check_embargo_date_format).returns(nil)

      ModsAsset.expects(:find).with("_PID_").returns(mock_document)
      
      simple_request_params = {"asset"=>{
          "descMetadata"=>{
            "subject"=>{"0"=>"subject1", "1"=>"subject2", "2"=>"subject3"}
          }
        }
      }

      # Hull custom controller filters that should be called
      controller.expects(:update_set_membership)
      controller.expects(:validate_parameters)
      # testing :update_document in more granular way
      # controller.expects(:update_document).with(mock_document, update_hash)
      mock_document.expects(:respond_to?).with(:apply_additional_metadata).returns(false)
      mock_document.expects(:update_datastream_attributes).with(simple_request_params["asset"]).returns({"subject"=>{"2"=>"My Topic"}})
      mock_document.expects(:save)
      # controller.expects(:display_release_status_notice)

      put :update, {:id=>"_PID_"}.merge(simple_request_params)
    end
    

    describe "a ukedt object" do
      before do
        @obj = UketdObject.new
        @obj.save
      end
      it "should add the object to structural and display sets" do
        simple_request_params = {
          "asset"=>{
            "descMetadata"=>{
              :title_info_main_title=>{"0"=>"Main Title"},
              :person_0_namePart =>{"0"=>"Author's name"},
              :origin_info_date_issued =>{"0" => ''}
            }
          },
          "field_selectors"=>{
            "descMetadata"=>{
              "title_info_main_title"=>[":title_info", ":main_title"],
              "person_0_namePart"=>[{":person"=>0}, ":namePart"],
              "origin_info_date_issued"=>[":origin_info", ":date_issued"]
            }
          }, 
          "content_type"=>"uketd_object",
          "Structural Set" => ["info:fedora/hull:3375"],
          "Display Set" => ["info:fedora/hull:700"]
        }

        put :update, {:id=>@obj.pid}.merge(simple_request_params)
        @updated = UketdObject.find(@obj.pid)
        @updated.relationships(:is_member_of).should include("info:fedora/hull:3375", "info:fedora/hull:700")
        @updated.relationships(:is_governed_by).should == ["info:fedora/hull:3375"]
      end
      after do
        #@obj.delete
      end
    end
  end
  
  describe "destroy" do
    it "should delete the asset identified by pid" do
      mock_obj = mock("asset", :delete)
      mock_obj.expects(:destroy_child_assets).returns([])
      #TODO  Look into why the next two expectations are happening twice
      ActiveFedora::Base.expects(:load_instance_from_solr).with("__PID__").returns(mock_obj).twice
      ActiveFedora::ContentModel.expects(:known_models_for).with(mock_obj).returns([UketdObject]).twice
      UketdObject.expects(:load_instance_from_solr).with("__PID__").returns(mock_obj)
      delete(:destroy, :id => "__PID__")
    end
  end
  
#  # withdraw is a conditional destroy, with the conditions dependant on the project requirements.
#  # Currently, the widthdraw method is an alias for destroy, should behave as such
#  describe "withdraw" do
#    it "should withdraw the asset identified by pid" do
#      mock_obj = mock("asset", :delete)
#      mock_obj.expects(:destroy_child_assets).returns([])
#      ActiveFedora::Base.expects(:load_instance_from_solr).with("__PID__").returns(mock_obj)
#      ActiveFedora::ContentModel.expects(:known_models_for).with(mock_obj).returns([HydrangeaArticle])
#      HydrangeaArticle.expects(:load_instance_from_solr).with("__PID__").returns(mock_obj)
#      delete(:withdraw, :id => "__PID__")
#    end
#  end
  
  
   
end
