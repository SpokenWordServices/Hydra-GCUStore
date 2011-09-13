require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


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
      @ss.defaultObjectRights.save
    end
    describe "with a non-structural set" do

      it "Should update the relationships for a non-Structural Set" do
        @document = ExamPaper.new
        controller = AssetsController.new
        controller.instance_variable_set :@document, @document
        controller.params = {'Structural Set' => "info:fedora/hull:3374" }
        
        controller.send :update_set_membership
        @document.relationships[:self][:is_member_of].should == ["info:fedora/hull:3374"]
        @document.relationships[:self][:is_governed_by].should == ["info:fedora/hull:3374"]
        @document.rightsMetadata.edit_access.machine.group.should == ['researcher']

        controller.params = {'Structural Set' => "info:fedora/hull:3374", 'Display Set' => 'info:fedora/hull:9' }
        controller.send :update_set_membership
        @document.relationships[:self][:is_member_of].should include("info:fedora/hull:3374", "info:fedora/hull:9")
        @document.relationships[:self][:is_governed_by].should == ["info:fedora/hull:3374"]

        controller.params = {'Display Set' => ['info:fedora/hull:9'] }
        controller.send :update_set_membership
        @document.relationships[:self][:is_member_of].should == ["info:fedora/hull:9"]
        @document.relationships[:self][:is_governed_by].should == ["info:fedora/hull:3374"]

        ### Deleting
        controller.params = {'Display Set' => [''] }
        controller.send :update_set_membership
        @document.relationships[:self][:is_member_of].should be_nil
        @document.relationships[:self][:is_governed_by].should == ["info:fedora/hull:3374"]

      end
    end
    it "Should update the relationships for a Structural Set" do
      @document = StructuralSet.new
      controller = AssetsController.new
      controller.instance_variable_set :@document, @document
      controller.params = {'Structural Set' => "info:fedora/hull:3374" }
      
      controller.send :update_set_membership
      @document.relationships[:self][:is_member_of].should == ["info:fedora/hull:3374"]
      @document.relationships[:self][:is_governed_by].should == ["info:fedora/hull-apo:structuralSet"]
      ## rightsMetadata should be a clone of hull-apo:structuralSet
      @document.rightsMetadata.edit_access.machine.group.should == ['contentAccessTeam']
      ## defaultObjectRights should be a clone of hull:3374
      @document.defaultObjectRights.edit_access.machine.group.should == ['researcher']

      controller.params = {'Structural Set' => "info:fedora/hull:3374", 'Display Set' => 'info:fedora/hull:9' }
      controller.send :update_set_membership
      @document.relationships[:self][:is_member_of].should include("info:fedora/hull:3374", "info:fedora/hull:9")
      @document.relationships[:self][:is_governed_by].should == ["info:fedora/hull-apo:structuralSet"]
      @document.rightsMetadata.edit_access.machine.group.should == ['contentAccessTeam']

      controller.params = {'Display Set' => ['info:fedora/hull:9'] }
      controller.send :update_set_membership
      @document.relationships[:self][:is_member_of].should == ["info:fedora/hull:9"]
      @document.relationships[:self][:is_governed_by].should == ["info:fedora/hull-apo:structuralSet"]
      @document.rightsMetadata.edit_access.machine.group.should == ['contentAccessTeam']

      ### Deleting
      controller.params = {'Display Set' => [''] }
      controller.send :update_set_membership
      @document.relationships[:self][:is_member_of].should be_nil
      @document.relationships[:self][:is_governed_by].should == ["info:fedora/hull-apo:structuralSet"]
      @document.rightsMetadata.edit_access.machine.group.should == ['contentAccessTeam']

    end

    after do
      @ss.defaultObjectRights.edit_access.machine.group= 'contentAccessTeam'
      @ss.defaultObjectRights.save
    end


  end
  
  describe "update" do
    
    it "should load the appropriate filters" do
      expected_filters = [:sanitize_update_params, :activate_authlogic, :default_html_head, :verify_authenticity_token, :store_bounce, :search_session, :history_session, :require_solr, :require_fedora, :check_embargo_date_format, :enforce_permissions, :load_document, :update_set_membership, :validate_parameters, :discard_flash_if_xhr]
      filters = AssetsController.filter_chain.map{|f| f.method }
      filters.should == expected_filters
    end
    
    it "should update the object with the attributes provided" do
      mock_document = mock("document")
      mock_document.stubs(:update_from_computing_id).returns(nil)
      mock_document.stubs(:respond_to?).with(:apply_governed_by).returns(true)
      controller.expects(:check_embargo_date_format).returns(nil)

      HydrangeaArticle.expects(:find).with("_PID_").returns(mock_document)
      
      simple_request_params = {"asset"=>{
          "descMetadata"=>{
            "subject"=>{"0"=>"subject1", "1"=>"subject2", "2"=>"subject3"}
          }
        }
      }

      # updated for hull
      mock_document.expects(:respond_to?).with(:valid_for_save?).returns(false)
      mock_document.expects(:respond_to?).with(:apply_additional_metadata).returns(false)
      mock_document.expects(:respond_to?).with(:apply_set_membership).returns(false)
      
      mock_document.expects(:update_datastream_attributes).with("descMetadata"=>{"subject"=>{"0"=>"subject1", "1"=>"subject2", "2"=>"subject3"}}).returns({"subject"=>{"2"=>"My Topic"}})
      mock_document.expects(:save)
      controller.stubs(:display_release_status_notice)
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
        @updated.relationships[:self][:is_member_of].should include("info:fedora/hull:3375", "info:fedora/hull:700")
        @updated.relationships[:self][:is_governed_by].should == ["info:fedora/hull:3375"]
      end
      after do
        @obj.delete
      end
    end
    
    it "should support updating OM::XML datastreams" do
      mock_document = mock("document")
      mock_document.stubs(:update_from_computing_id).returns(nil)
      # content_type is specified as hydrangea_dataset.  If not specified, it defaults to HydrangeaArticle
      HydrangeaDataset.expects(:find).with("_PID_").returns(mock_document)
      
      update_method_args = [ "descMetadata" => { [{:person=>0}, :role] => {"0"=>"role1","1"=>"role2","2"=>"role3"} } ]
      # updated for hull
      mock_document.expects(:respond_to?).with(:valid_for_save?).returns(false)
      mock_document.expects(:respond_to?).with(:apply_set_membership).returns(false)
      mock_document.expects(:respond_to?).with(:apply_additional_metadata).returns(false)
      mock_document.expects(:respond_to?).with(:apply_governed_by).returns(true)
      mock_document.expects(:update_datastream_attributes).with( *update_method_args ).returns({"person_0_role"=>{"0"=>"role1","1"=>"role2","2"=>"role3"}})
      mock_document.expects(:save)
      
      
      nokogiri_request_params = {
        "id"=>"_PID_", 
        "content_type"=>"hydrangea_dataset",
        "field_selectors"=>{
          "descMetadata"=>{
            "person_0_role"=>[{":person"=>"0"}, "role"]
          }
        }, 
        "asset"=>{
          "descMetadata"=>{
            "person_0_role"=>{"0"=>"role1", "1"=>"role2", "2"=>"role3"}
          }
        }
      }
      controller.stubs(:display_release_status_notice)
      put :update, nokogiri_request_params
      # put :update, :id=>"_PID_", "content_type"=>"hydrangea_article", "datastream"=>"descMetadata", "field_name"=>"person_0_last_name","parent_select"=>[{":person"=>"0"}, ":last_name"], "child_index"=>"0", "value"=>"Sample New Value"
    end
    
    it "should handle complete updates of many fields in many datastreams" do
      pending("This is failing intermittently. See https://jira.duraspace.org/browse/HYDRUS-166 for more info")
      request_params = {"id"=>"hydrangea:fixture_mods_article3", "content_type"=>"hydrangea_article", "action"=>"update", "_method"=>"put"}
      request_params["field_selectors"] = {"descMetadata"=>{"person_0_computing_id"=>[{"person"=>"0"}, "computing_id"], "journal_0_issue_start_page"=>[{"journal"=>"0"}, "issue", "start_page"], "person_1_description"=>[{"person"=>"1"}, "description"], "person_1_institution"=>[{"person"=>"1"}, "institution"], "journal_0_origin_info_publisher"=>[{"journal"=>"0"}, "origin_info", "publisher"], "abstract"=>["abstract"], "person_0_last_name"=>[{"person"=>"0"}, "last_name"], "person_0_description"=>[{"person"=>"0"}, "description"], "journal_0_issue_volume"=>[{"journal"=>"0"}, "issue", "volume"], "title_info_main_title"=>["title_info", "main_title"], "location_url"=>["location", "url"], "note"=>["note"], "person_1_last_name"=>[{"person"=>"1"}, "last_name"], "subject_topic"=>["subject", "topic"], "person_0_institution"=>[{"person"=>"0"}, "institution"], "person_1_first_name"=>[{"person"=>"1"}, "first_name"], "person_1"=>[{"person"=>"1"}], "journal_0_title_info_main_title"=>[{"journal"=>"0"}, "title_info", "main_title"], "journal_0_issue_level"=>[{"journal"=>"0"}, "issue", "level"], "journal_0_issue_end_page"=>[{"journal"=>"0"}, "issue", "end_page"], "peer_reviewed"=>["peer_reviewed"], "person_0_first_name"=>[{"person"=>"0"}, "first_name"], "person_1_computing_id"=>[{"person"=>"1"}, "computing_id"], "journal_0_issn"=>[{"journal"=>"0"}, "issn"], "journal_0_issue_publication_date"=>[{"journal"=>"0"}, "issue", "publication_date"]}, "rightsMetadata"=>{"embargo_embargo_release_date"=>["embargo", "embargo_release_date"]}, "properties"=>{"release_to"=>["release_to"]}} 
      request_params["asset"] = {"descMetadata"=>{"person_0_computing_id"=>{"0"=>""}, "journal_0_issue_start_page"=>{"0"=>"195"}, "person_1_description"=>{"0"=>""}, "person_1_institution"=>{"0"=>"Baltimore"}, "journal_0_origin_info_publisher"=>{"0"=>"PUBLISHER"}, "abstract"=>{"0"=>"ABSTRACT"}, "person_0_last_name"=>{"0"=>"Smith"}, "person_0_description"=>{"0"=>""}, "journal_0_issue_volume"=>{"0"=>"2               "}, "title_info_main_title"=>{"0"=>"Test Article"}, "location_url"=>{"0"=>"http://example.com/foo"}, "note"=>{"0"=>""}, "person_1_last_name"=>{"0"=>"Lacks"}, "subject_topic"=>{"0"=>"TOPIC 1", "1"=>"TOPIC 2", "2"=>"CONTROLLED TERM"}, "person_0_institution"=>{"0"=>"FACULTY, UNIVERSITY"}, "person_1_first_name"=>{"0"=>"Henrietta"}, "journal_0_title_info_main_title"=>{"0"=>"The Journal of Mock Object"}, "journal_0_issue_level"=>{"0"=>""}, "journal_0_issue_end_page"=>{"0"=>"230"}, "person_0_first_name"=>{"0"=>"John"}, "person_1_computing_id"=>{"0"=>""}, "journal_0_issn"=>{"0"=>"1234-5678"}, "journal_0_issue_publication_date"=>{"0"=>"FEB. 2007"}}, "rightsMetadata"=>{"embargo_embargo_release_date"=>{"0"=>""}}, "properties"=>{"released"=>{"0"=>"true"}, "release_to"=>{"0"=>"public"}}}
      expected_response = {"descMetadata"=>{"journal_0_issue_start_page"=>{"0"=>"195"}, "person_0_computing_id"=>{"-1"=>""}, "abstract"=>{"0"=>"ABSTRACT"}, "journal_0_origin_info_publisher"=>{"0"=>"PUBLISHER"}, "person_1_description"=>{"-1"=>""}, "person_1_institution"=>{"0"=>"Baltimore"}, "journal_0_issue_volume"=>{"0"=>"2               "}, "person_0_description"=>{"-1"=>""}, "person_0_last_name"=>{"0"=>"Smith"}, "title_info_main_title"=>{"0"=>"Test Article"}, "note"=>{"-1"=>""}, "location_url"=>{"0"=>"http://example.com/foo"}, "person_1_last_name"=>{"0"=>"Lacks"}, "subject_topic"=>{"0"=>"TOPIC 1", "1"=>"TOPIC 2", "2"=>"CONTROLLED TERM"}, "journal_0_issue_end_page"=>{"0"=>"230"}, "journal_0_title_info_main_title"=>{"0"=>"The Journal of Mock Object"}, "journal_0_issue_level"=>{"-1"=>""}, "person_1_first_name"=>{"0"=>"Henrietta"}, "person_0_institution"=>{"0"=>"FACULTY, UNIVERSITY"}, "journal_0_issn"=>{"0"=>"1234-5678"}, "person_0_first_name"=>{"0"=>"John"}, "person_1_computing_id"=>{"-1"=>""}, "journal_0_issue_publication_date"=>{"0"=>"FEB. 2007"}}, "rightsMetadata"=>{"embargo_embargo_release_date"=>{"-1"=>""}}, "properties"=>{:released=>{"0"=>"true"}, [:release_to]=>{}, :release_to=>{"0"=>"public"}}}
      
      post :update, request_params
      expected_response.each_pair do |datastream_name, fields|
        fields.each_pair do |field_pointer, value|
          assigns[:response][datastream_name][field_pointer].should == value
        end
      end  
    end
  end
  
  describe "destroy" do
    it "should delete the asset identified by pid" do
      mock_obj = mock("asset", :delete)
      mock_obj.expects(:destroy_child_assets).returns([])
      ActiveFedora::Base.expects(:load_instance_from_solr).with("__PID__").returns(mock_obj)
      ActiveFedora::ContentModel.expects(:known_models_for).with(mock_obj).returns([HydrangeaArticle])
      HydrangeaArticle.expects(:load_instance_from_solr).with("__PID__").returns(mock_obj)
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
