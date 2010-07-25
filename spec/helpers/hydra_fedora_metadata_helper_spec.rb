require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HydraFedoraMetadataHelper do
  
  before(:all) do
    # @mock_ng_ds = mock("nokogiri datastream")
    # @mock_ng_ds.stubs(:kind_of?).with(ActiveFedora::NokogiriDatastream).returns(true)
    # @mock_ng_ds.stubs(:class).returns(ActiveFedora::NokogiriDatastream)
    # @mock_md_ds = stub(:stream_values=>"value")
    # datastreams = {"ng_ds"=>@mock_ng_ds,"simple_ds"=>@mock_md_ds}
    @resource = mock("fedora object")
    # @resource.stubs(:datastreams).returns(datastreams)
    # @resource.stubs(:datastreams_in_memory).returns(datastreams)
        
    @resource.stubs(:get_values_from_datastream).with("simple_ds", "subject", "").returns( ["topic1","topic2"] )

    @resource.stubs(:get_values_from_datastream).with("ng_ds", [:title, :main_title], "").returns( ["My Title"] )
    @resource.stubs(:get_values_from_datastream).with("ng_ds", [{:person=>1}, :given_name], "").returns( ["Bob"] )

    @resource.stubs(:get_values_from_datastream).with("empty_ds", "something", "").returns( [] )

  end
  
  describe "fedora_text_field" do
    it "should generate a text field input with values from the given datastream" do
      generated_html = helper.fedora_text_field(@resource,"ng_ds",[:title, :main_title])
      generated_html.should match(/<li class="editable-container" id="title_main_title_0-container">.*<\/li>/)
      generated_html.should match(/<span class="editable-text" id="title_main_title_0-text">My Title<\/span>/)
      generated_html.should match(/<input class="editable-edit" id="title_main_title_0" name="asset\[ng_ds\]\[title_main_title_0\]" value="My Title"\/>/)
      # generated_html.should match(//)
    end
    it "should include any necessary field_selector values" do
      generated_html = helper.fedora_text_field(@resource,"ng_ds",[:title, :main_title])
      generated_html.should match(  helper.field_selectors_for("ng_ds",[:title, :main_title]) )
    end
    it "should generate an ordered list of text field inputs" do
      generated_html = helper.fedora_text_field(@resource,"simple_ds","subject")
      generated_html.should match(/<ol.*>.*<\/ol>/)                                                                                                          
      generated_html.should match(/<li class="editable-container" id="subject_0-container">.*<\/li>/) 
      generated_html.should match(/<input class="editable-edit" id="subject_0" name="asset\[simple_ds\]\[subject_0\]" value="topic1"\/>/)
                                                                                                               
      generated_html.should match(/<li class="editable-container" id="subject_1-container">.*<\/li>/)        
      generated_html.should match(/<input class="editable-edit" id="subject_1" name="asset\[simple_ds\]\[subject_1\]" value="topic2"\/>/)                                                                                           
    end
    it "should limit to single-value output with no ordered list if :multiple=>false" do
      generated_html = helper.fedora_text_field(@resource,"simple_ds","subject", :multiple=>false)
      generated_html.should_not match(/<ol.*>.*<\/ol>/)                                                                                                          
      generated_html.should_not match(/<li.*>.*<\/li>/)
      
      generated_html.should match(/<span class="editable-container" id="subject-container">.*<\/span>/)
      generated_html.should match(/<span class="editable-text" id="subject-text">topic1<\/span>/)
      generated_html.should match(/<input class="editable-edit" id="subject" name="asset\[simple_ds\]\[subject\]" value="topic1"\/>/)                                                                                                                                                                                                   
    end
  end
  
  describe "fedora_text_area" do
    it "should generate a textile-enabled text area with values from the given datastream" 
    it "should generate an ordered list of text field inputs if there are multiple values"
    it "should limit to single-value output if :multiple=>false"
  end
  
  describe "fedora_select" do
    it "should generate a select with values from the given datastream" 
  end
  
  describe "fedora_checkbox" do
    it "should generate a set of checkboxes with values from the given datastream" 
  end
  
  describe "all field generators" do
    it "should include any necessary field_selector info" 
  end
  
  describe "fedora_text_field_insert_link" do
    it "should generate a link for inserting a fedora_text_field into the page" 
  end
  
  describe "fedora_text_area_insert_link" do
    it "should generate a link for inserting a fedora_text_area into the page" 
  end
  
  describe "field_selectors_for" do
    it "should generate any necessary field_selector values for the given field" do
      helper.field_selectors_for("myDsName", [{:name => 3}, :name_part]).should match_html('<input type="hidden" rel="name_3_name_part" name="field_selectors[myDsName][name_3_name_part][][name]" value="3" /><input type="hidden" rel="name_3_name_part" name="field_selectors[myDsName][name_3_name_part][]" value="name_part" />')
    end
    it "should not generate any field selectors if the field key is not an array" do
      helper.field_selectors_for("myDsName", :description).should == ""
    end
  end
  
  describe "hydra_form_for" do
    it "should generate an entire form" do
      pending
      eval_erb(%(
        <% hydra_form_for @resource do |h| %>
          <h2>Hello</h2>
          <%= h.fedora_text_field %>
        <% end %>
      )).should match_html("<h2>Hello</h2> blah blah blah ")
    end
  end
end