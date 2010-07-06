require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


# See cucumber tests (ie. /features/edit_document.feature) for more tests, including ones that test the edit method & view
# You can run the cucumber tests with 
#
# cucumber --tags @edit
# or
# rake cucumber

describe PermissionsController do
  describe "index" do
    it "should retrieve the object's rightsMetadata datastream as a Hydra::RightsMetadata object and render the _index partial" do
    end
  end
  describe "show" do
    it"should render different partial based on the permission type" do
      pending
      renders "permissions/edit_individual"
      renders "permissions/edit_group"
    end
  end
  describe "edit" do
  end
  describe "new" do
    it "should render the _new partial"
  end
  describe "create" do
    it "should rely on .update method"
  end
  describe "update" do
    it "should call Hydra::RightsMetadata properties setter"
    it "should add a rightsMetadata datastream if it doesn't exist"
    it "should not cause the metadata to be indexed twice" do
      # should load the object as ActiveFedora::Base, initialize the rightsMetadata datastream as Hydra::RightsMetadata, update the datastream, save the datastream, and tell Solrizer to re-index the object from pid
      # re-indexing from pid rather than passing in the current object prevents double-indexing of the edited metadatata datastream
    end
  end
end
