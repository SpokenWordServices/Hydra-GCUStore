require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'mocha'

# See cucumber tests (ie. /features/edit_document.feature) for more tests, including ones that test the edit method & view
# You can run the cucumber tests with 
#
# cucumber --tags @edit
# or
# rake cucumber

describe CatalogController do
  
  before do
    #controller.stubs(:protect_from_forgery).returns("meh")
    session[:user]='bob'
  end
  
  it "should use CatalogController" do
    controller.should be_an_instance_of(CatalogController)
  end
  
  it "should be restful" do
    pending
    route_for(:controller=>'catalog', :action=>'index').should == '/'
    # route_for(:controller=>'catalog', :action=>'index').should == '/catalog'
    route_for(:controller=>'catalog', :action=>'show', :id=>"_PID_").should == '/catalog/_PID_'
    route_for(:controller=>'catalog', :action=>'edit', :id=>"_PID_").should == '/catalog/_PID_/edit'

    params_from(:get, '/catalog').should == {:controller=>'catalog', :action=>'index'}
    params_from(:get, '/catalog/_PID_').should == {:controller=>'catalog', :id=>"_PID_", :action=>'show'}
    params_from(:get, '/catalog/_PID_/edit').should == {:controller=>'catalog', :id=>"_PID_", :action=>'edit'}
  end

  it "should be restful at hull" do
    pending
    route_for(:controller=>'catalog', :action=>'index').should == '/'
    # route_for(:controller=>'catalog', :action=>'index').should == '/catalog'
    route_for(:controller=>'catalog', :action=>'show', :id=>"_PID_").should == '/resources/_PID_'
    route_for(:controller=>'catalog', :action=>'edit', :id=>"_PID_").should == '/resources/_PID_/edit'

    params_from(:get, '/resources').should == {:controller=>'catalog', :action=>'index'}
    params_from(:get, '/resources/_PID_').should == {:controller=>'catalog', :id=>"_PID_", :action=>'show'}
    params_from(:get, '/resources/_PID_/edit').should == {:controller=>'catalog', :id=>"_PID_", :action=>'edit'}
  end


  describe "index" do
    describe "access controls" do
      before(:all) do
        @public_document = SaltDocument.new(:pid=>"test:public_document")
        @public_document.datastreams["properties"].access_values = "public"
        extracted = ActiveFedora::Datastream.new(:dsid=>"extProperties")
        extracted.content = fixture("druid-bv448hq0314-extProperties.xml").read
        @public_document.add_datastream( extracted )
        @public_document.save
        
        @private_document = SaltDocument.new(:pid=>"test:private_document")
        @private_document.datastreams["properties"].access_values = "private"
        extracted = ActiveFedora::Datastream.new(:dsid=>"extProperties")
        extracted.content = fixture("druid-bv448hq0314-extProperties.xml").read
        @private_document.add_datastream( extracted )
        @private_document.save
        
        @public_only_results = Blacklight.solr.find Hash[:phrases=>{:access_t=>"public"}]
        @private_only_results = Blacklight.solr.find Hash[:phrases=>{:access_t=>"private"}]

      end
      after(:all) do
        connect_bl_solr
        @public_document.delete
        @bl_solr.delete("test\:public_document")
        @private_document.delete
        @bl_solr.delete("test\:private_document")
      end
      it "should only return public documents if role does not have permissions" do
        pending("FIXME")
        request.env["WEBAUTH_USER"]="Mr. Notallowed"
        get :index
        assigns("response").docs.count.should == @public_only_results.docs.count
      end
      it "should return all documents if role does have permissions" do
        pending("adjusted for superuser, but assertions aren't working as with test above")
        mock_user = mock("User", :login=>"BigWig")
        session[:superuser_mode] = true
        controller.stubs(:current_user).returns(mock_user)
        get :index
        # assigns["response"].docs.should include(@public_only_results.first)
        # assigns["response"].docs.should include(@private_only_results.first)
        assigns["response"].docs.count.should > @public_only_results.docs.count
      end
    end
  end
  
  describe "show" do
    describe "access controls" do
      it "should deny access to documents if role does not have permissions" do
        pending
        request.env["WEBAUTH_USER"]="Mr. Notallowed"
        get :show, :id=>"druid:fs442rd9742"
        response.should redirect_to(:action => 'show')
        flash[:message].should == "You do not have sufficient privileges to view this document."
      end
    end
  end
  
  
end
