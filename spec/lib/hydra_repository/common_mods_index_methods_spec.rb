# Need way to find way to stub current_user and RoleMapper in order to run these tests
require File.expand_path( File.join( File.dirname(__FILE__), '..','..','spec_helper') )


describe Hydra::CommonModsIndexMethods do
  describe "extract_person_full_names" do
    it "should return an array of Solr::Field objects for :person_full_name_facet" do
      full_names = HydrangeaArticle.find("hydrangea:fixture_mods_article1").datastreams["descMetadata"].extract_person_full_names
      full_names.should be_kind_of Array
      full_names.length.should == 2
      full_names.first.should be_kind_of Solr::Field
      full_names.last.should be_kind_of Solr::Field
    end
  end
  describe "extract_person_organizations" do 
    it "should return an array of Solr::Field objects for :mods_organization_facet" do
      orgs = HydrangeaArticle.find("hydrangea:fixture_mods_article1").datastreams["descMetadata"].extract_person_organizations
      orgs.should be_kind_of Array
      orgs.length.should == 2
      orgs.first.should be_kind_of Solr::Field
      orgs.last.should be_kind_of Solr::Field
    end
  end
end


