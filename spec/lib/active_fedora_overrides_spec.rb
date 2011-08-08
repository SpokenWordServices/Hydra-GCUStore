require File.join( File.dirname(__FILE__), "../spec_helper" )

require 'active_fedora'
require 'mocha'

class FooHistory < ActiveFedora::Base
  has_metadata :type=>ActiveFedora::MetadataDatastream, :name=>"someData" do |m|
    m.field "fubar", :string
    m.field "swank", :text
  end
  has_metadata :type=>ActiveFedora::MetadataDatastream, :name=>"withText" do |m|
    m.field "fubar", :text
  end
  has_metadata :type=>ActiveFedora::MetadataDatastream, :name=>"withText2", :label=>"withLabel" do |m|
    m.field "fubar", :text
  end 
  
#  has_metadata :type=>ActiveFedora::MetadataDatastream, :name=>"managed", :control_group => "M" do |m|
#    m.field "fubar", :text
#  end
#  has_metadata :type=>ActiveFedora::NokogiriDatastream, :name=>"externalDisseminator", :control_group => "E", :disseminator => "af-sDef:fooHistory/getFooHistoryMetadata"
end


describe ActiveFedora::ContentModel do
  
  before(:each) do
    Fedora::Repository.instance.stubs(:nextid).returns("_nextid_")
    @test_cmodel = ActiveFedora::ContentModel.new
  end
  
  it 'should provide #pid_from_ruby_class' do
    ActiveFedora::ContentModel.should respond_to(:pid_from_ruby_class)
  end
  
  describe "#pid_from_ruby_class" do
    it "should construct pids" do
     ActiveFedora::ContentModel.pid_from_ruby_class(@test_cmodel.class).should == "afmodel:activeFedora_ContentModel"
     ActiveFedora::ContentModel.pid_from_ruby_class(@test_cmodel.class, :namespace => "foo", :pid_suffix => "BarBar").should == "foo:activeFedora_ContentModelBarBar"
    end
    it "should construct pids with the namespace declared in the model" do
      ActiveFedora::ContentModel.stubs(:pid_namespace).returns("test-cModel")
      ActiveFedora::ContentModel.pid_from_ruby_class(@test_cmodel.class).should == "test-cModel:activeFedora_ContentModel"
    end
    it "should construct pids with the suffix declared in the model" do
      ActiveFedora::ContentModel.stubs(:pid_suffix).returns("-TEST-SUFFIX")
      ActiveFedora::ContentModel.pid_from_ruby_class(@test_cmodel.class).should == 'afmodel:activeFedora_ContentModel-TEST-SUFFIX'
    end
    it "should construct hull pids correctly" do
      ActiveFedora::ContentModel.pid_from_ruby_class(UketdObject).should eql('hull-cModel:uketdObject')
      ActiveFedora::ContentModel.pid_from_ruby_class(ExamPaper).should eql('hull-cModel:examPaper')
      ActiveFedora::ContentModel.pid_from_ruby_class(MeetingPaper).should eql('hull-cModel:meetingPaper')
      ActiveFedora::ContentModel.pid_from_ruby_class(GenericContent).should eql('hull-cModel:genericContent')
      ActiveFedora::ContentModel.pid_from_ruby_class(StructuralSet).should eql('hull-cModel:structuralSet')
      ActiveFedora::ContentModel.pid_from_ruby_class(Presentation).should eql('hull-cModel:presentation')
      ActiveFedora::ContentModel.pid_from_ruby_class(JournalArticle).should eql('hull-cModel:journalArticle')
    end
  end
  
  describe "#uri_to_ruby_class" do
    it "should correctly return the ruby class of a given uri" do
      ActiveFedora::ContentModel.uri_to_ruby_class("info:fedora/hull-cModel:uketdObject").should eql(UketdObject)
      ActiveFedora::ContentModel.uri_to_ruby_class("info:fedora/hull-cModel:examPaper").should eql(ExamPaper)
      ActiveFedora::ContentModel.uri_to_ruby_class("info:fedora/hull-cModel:meetingPaper").should eql(MeetingPaper)
      ActiveFedora::ContentModel.uri_to_ruby_class("info:fedora/hull-cModel:genericContent").should eql(GenericContent)
      ActiveFedora::ContentModel.uri_to_ruby_class("info:fedora/hull-cModel:structuralSet").should eql(StructuralSet)
      ActiveFedora::ContentModel.uri_to_ruby_class("info:fedora/hull-cModel:presentation").should eql(Presentation)
      ActiveFedora::ContentModel.uri_to_ruby_class("info:fedora/hull-cModel:journalArticle").should eql(JournalArticle)
    end
  end
end

describe ActiveFedora::Base do

  it "should respond_to has_metadata" do
    ActiveFedora::Base.respond_to?(:has_metadata).should be_true
  end
  
  context "original implementation" do

    before :each do
      @n = FooHistory.new(:pid=>"monkey:99")
      @n.save
    end

    after :each do
      begin
        @n.delete
      rescue
      end
    end

    it "has_metadata should create specified datastreams with specified fields" do
      @n.datastreams["someData"].should_not be_nil
      @n.datastreams["someData"].fubar_values='bar'
      @n.datastreams["someData"].fubar_values.should == ['bar']
      @n.datastreams["withText2"].label.should == "withLabel"
    end
  end

  context "overriding implementation" do
    describe "has_metadata" do
#      before :each do
#        @n = UketdObject.new(:pid=>"monkey:99")
#        @n.save
#      end

      after :each do
        begin
          @n.delete
        rescue
        end
        Object.send(:remove_const,:MoreFooHistory) if defined?(MoreFooHistory)
      end
      
      it "should create specified datastreams with appropriate control group" do
        @n = UketdObject.new(:pid=>"monkey:99")
        @n.save
        @n.datastreams["DC"].attributes[:controlGroup].should eql("X")
        @n.datastreams["rightsMetadata"].attributes[:controlGroup].should eql("X")
        @n.datastreams["properties"].attributes[:controlGroup].should eql("X")
        @n.datastreams["descMetadata"].attributes[:controlGroup].should eql("M")
        @n.datastreams["contentMetadata"].attributes[:controlGroup].should eql("M")
        @n.datastreams["UKETD_DC"].attributes[:controlGroup].should eql("E")
      end

      context ":control_group => 'E'" do
        it "should raise an error without :disseminator or :url option" do
          class MoreFooHistory < ActiveFedora::Base
            has_metadata :type=>ActiveFedora::NokogiriDatastream, :name=>"externalDisseminator", :control_group => "E"
          end
          lambda { @n = MoreFooHistory.new }.should raise_exception
        end
        
        it "should allow :control_group => 'E' with a :url option" do
          class MoreFooHistory < ActiveFedora::Base
            has_metadata :type=>ActiveFedora::MetadataDatastream, :name=>"externalDisseminator",:control_group => "E", :url => "http://exampl.com/mypic.jpg"
          end
          @n = MoreFooHistory.new
          @n.save
        end
        it "should raise an error if :url is malformed" do
          class MoreFooHistory < ActiveFedora::Base
            has_metadata :type => ActiveFedora::NokogiriDatastream, :name=>"externalUrl", :url=>"my_rul", :control_group => "E"
          end
          @n = MoreFooHistory.new
          lambda {@n.save }.should raise_exception
        end
      end

      context ":control_group => 'R'" do
        it "should raise an error without :url option" do
          class MoreFooHistory < ActiveFedora::Base
            has_metadata :type=>ActiveFedora::NokogiriDatastream, :name=>"externalDisseminator", :control_group => "R"
          end
          lambda { @n = MoreFooHistory.new }.should raise_exception
        end
        
        it "should work with a valid  :url option" do
          class MoreFooHistory < ActiveFedora::Base
            has_metadata :type=>ActiveFedora::MetadataDatastream, :name=>"externalDisseminator",:control_group => "R", :url => "http://exampl.com/mypic.jpg"
          end
          @n = MoreFooHistory.new
          @n.save
        end
        it "should not take a :disseminator option without a :url option" do
          class MoreFooHistory < ActiveFedora::Base
            has_metadata :type=>ActiveFedora::NokogiriDatastream, :name=>"externalDisseminator", :control_group => "R", :disseminator => "foo:s-def/hull-cModel:Foo"
          end
          lambda { @n = MoreFooHistory.new }.should raise_exception
        end
        it "should raise an error if :url is malformed" do
          class MoreFooHistory < ActiveFedora::Base
            has_metadata :type => ActiveFedora::NokogiriDatastream, :name=>"externalUrl", :url=>"my_rul", :control_group => "R"
          end
          @n = MoreFooHistory.new
          lambda {@n.save }.should raise_exception
        end
      end
    end
  end
end
