require "spec_helper"


describe ActiveFedora::ContentModel do
  
  before(:each) do
    @test_cmodel = ActiveFedora::ContentModel.new
  end
  
  it 'should provide #pid_from_ruby_class' do
    ActiveFedora::ContentModel.should respond_to(:pid_from_ruby_class)
  end
  
  describe "#pid_from_ruby_class" do
    it "should construct pids" do
     ActiveFedora::ContentModel.pid_from_ruby_class(@test_cmodel.class).should == "info:fedora/afmodel:activeFedora_ContentModel"
     ActiveFedora::ContentModel.pid_from_ruby_class(@test_cmodel.class, :namespace => "foo", :pid_suffix => "BarBar").should == "info:fedora/foo:activeFedora_ContentModelBarBar"
    end
    it "should construct pids with the namespace declared in the model" do
      ActiveFedora::ContentModel.stubs(:pid_namespace).returns("test-cModel")
      ActiveFedora::ContentModel.pid_from_ruby_class(@test_cmodel.class).should == "info:fedora/test-cModel:activeFedora_ContentModel"
    end
    it "should construct pids with the suffix declared in the model" do
      ActiveFedora::ContentModel.stubs(:pid_suffix).returns("-TEST-SUFFIX")
      ActiveFedora::ContentModel.pid_from_ruby_class(@test_cmodel.class).should == 'info:fedora/afmodel:activeFedora_ContentModel-TEST-SUFFIX'
    end
    it "should construct hull pids correctly" do
      ActiveFedora::ContentModel.pid_from_ruby_class(UketdObject).should eql('info:fedora/hull-cModel:uketdObject')
      ActiveFedora::ContentModel.pid_from_ruby_class(ExamPaper).should eql('info:fedora/hull-cModel:examPaper')
      ActiveFedora::ContentModel.pid_from_ruby_class(GenericContent).should eql('info:fedora/hull-cModel:genericContent')
      ActiveFedora::ContentModel.pid_from_ruby_class(StructuralSet).should eql('info:fedora/hull-cModel:structuralSet')
      ActiveFedora::ContentModel.pid_from_ruby_class(JournalArticle).should eql('info:fedora/hull-cModel:journalArticle')
    end
  end
  
  describe "#uri_to_ruby_class" do
    it "should correctly return the ruby class of a given uri" do
      ActiveFedora::ContentModel.uri_to_model_class("info:fedora/hull-cModel:uketdObject").should eql(UketdObject)
      ActiveFedora::ContentModel.uri_to_model_class("info:fedora/hull-cModel:examPaper").should eql(ExamPaper)
      ActiveFedora::ContentModel.uri_to_model_class("info:fedora/hull-cModel:genericContent").should eql(GenericContent)
      ActiveFedora::ContentModel.uri_to_model_class("info:fedora/hull-cModel:structuralSet").should eql(StructuralSet)
      ActiveFedora::ContentModel.uri_to_model_class("info:fedora/hull-cModel:journalArticle").should eql(JournalArticle)
    end
  end
end

