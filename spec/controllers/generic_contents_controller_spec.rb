require 'spec_helper'

describe GenericContentsController do
  describe "new" do
    it "should be successfull" do
      get :new
      response.should be_success
    end
  end
  describe "create" do
    describe "for content access team members" do
      before(:each) do
        sign_in FactoryGirl.find_or_create(:cat)
      end
      it "should apply posted attributes" do
        post :create, {:id=>"foo:pid", "Structural Set"=>["info:fedora/hull:3374"], "commit"=>"Save", 
          "generic_content"=>{"geographic_tag"=>"My Geo Tag",
                              "temporal_tag"=>"My Temporal Tag",
                              "coordinates"=>"My Coordinates", 
                              "date_valid"=>"2022", 
                              "type_of_resource"=>"text", 
                              "title"=>"Foo Test Generic Object", 
                              "topic_tag"=>"My Topic Tag", 
                              "rights"=>"lorem ipsum rightso facto", 
                              "digital_origin"=>"My digital origin", 
                              "publisher"=>"Das Publisher", 
                              "description"=>"lorem ipsum descripto facto", 
                              "lang_code"=>"eng", 
                              "related_item"=>"http://google.com", 
                              "see_also"=>"http://bing.com", 
                              "lang_text"=>"English", 
                              'genre'=>'Policy or procedure',
                              'person'=>{'0'=>{"role"=>{"text"=>"Author"}, 'namePart'=>'Joe'}}}, 
          "Display Set"=>["info:fedora/hull:domesdayDisplaySet"]}
        assigns[:generic_content].geographic_tag.should == ["My Geo Tag"]
        assigns[:generic_content].temporal_tag.should == ["My Temporal Tag"]
        assigns[:generic_content].topic_tag.should == ["My Topic Tag"]
        assigns[:generic_content].coordinates.should == ["My Coordinates"]
        assigns[:generic_content].date_valid.should == ["2022"]
        assigns[:generic_content].type_of_resource.should == ["text"]
        assigns[:generic_content].title.should == ["Foo Test Generic Object"]
        assigns[:generic_content].rights.should == ["lorem ipsum rightso facto"]
        assigns[:generic_content].description.should == ["lorem ipsum descripto facto"]
        assigns[:generic_content].digital_origin.should == ["My digital origin"]
        assigns[:generic_content].publisher.should == ["Das Publisher"]
        assigns[:generic_content].lang_code.should == ["eng"]
        assigns[:generic_content].related_item.should == ["http://google.com"]
        assigns[:generic_content].see_also.should == ["http://bing.com"]
        assigns[:generic_content].lang_text.should == ["English"]    
        assigns[:generic_content].relationships(:has_model).should == ["info:fedora/hull-cModel:policy", "info:fedora/hydra-cModel:compoundContent","info:fedora/hydra-cModel:commonMetadata"]    
        assigns[:generic_content].descMetadata.person(0).namePart.should == ['Joe']
        assigns[:generic_content].descMetadata.person(0).role.text.should == ['Author']

      end
      it "should apply set memberships and queue" do 
        post :create, {:id=>"foo:pid", "Structural Set"=>["info:fedora/hull:3374"], "commit"=>"Save", "generic_content"=>{"geographic_tag"=>"", "temporal_tag"=>"", "coordinates"=>"", "date_valid"=>"", "type_of_resource"=>"", "title"=>"Foo Test Generic Object", "topic_tag"=>"", "rights"=>"", "digital_origin"=>"", "publisher"=>"", "description"=>"", "lang_code"=>"", "related_item"=>"", "see_also"=>"", "lang_text"=>"", 'genre'=>'Generic content'}, "Display Set"=>["info:fedora/hull:domesdayDisplaySet"]}
        assigns[:generic_content].display_set.should == "info:fedora/hull:domesdayDisplaySet"
        # assigns[:generic_content].structural_set.should == "info:fedora/hull:3374"
        #assigns[:generic_content].is_governed_by.should == ["info:fedora/hull:3374"]
				#All new objects are governed by the queue until it is published
				assigns[:generic_content].is_governed_by.should == ["info:fedora/hull:protoQueue"]
        ["info:fedora/hull:domesdayDisplaySet", "info:fedora/hull:protoQueue", "info:fedora/hull:3374"].each do |set_uri| 
          assigns[:generic_content].set_membership.should include(set_uri)
        end
      end
    end
    describe "when not logged in" do
      before do
        sign_out :user
      end
      it "should deny access" do
        GenericContent.expects(:new).never
        post :create, :id=>"foo:pid", "Structural Set"=>["info:fedora/hull:3374"], "Display Set"=>["info:fedora/hull:domesdayDisplaySet"], "commit"=>"Save", "generic_content"=>{"geographic_tag"=>"", "temporal_tag"=>"", "coordinates"=>"", "date_valid"=>"", "type_of_resource"=>"", "title"=>"Foo Test Generic Object", "topic_tag"=>"", "rights"=>"", "digital_origin"=>"", "publisher"=>"", "description"=>"", "lang_code"=>"", "related_item"=>"", "see_also"=>"", "lang_text"=>""}
        response.should be_redirect
      end
    end
  end
end
