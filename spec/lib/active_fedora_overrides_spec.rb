require File.join( File.dirname(__FILE__), "../spec_helper" )

require 'active_fedora'
require 'mocha'


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
