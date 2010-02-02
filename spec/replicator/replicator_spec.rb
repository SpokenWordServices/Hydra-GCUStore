require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Shelver::Replicator do
  
  before(:all) do
    config_path = "#{RAILS_ROOT}/config/replicator.yml"
    @raw_replicator_configs = YAML::load(File.open(config_path))
    @replicator_configs = @raw_replicator_configs[RAILS_ENV]
    @sample_object = Document.new
    properties_xml = fixture("sample_object/sample_object-properties.xml")
    properties_ds = ActiveFedora::Datastream.new(:dsid=>"properties", :label=>"properties", :blob=>properties_xml.read)
    ext_properties_xml = fixture("sample_object/sample_object-extProperties.xml")
    ext_properties_ds = ActiveFedora::Datastream.new(:dsid=>"extProperties", :label=>"extProperties", :blob=>ext_properties_xml.read)
    desc_metadata_xml = fixture("sample_object/sample_object-descMetadata.xml")
    desc_metadata_ds = ActiveFedora::Datastream.new(:dsid=>"descMetadata", :label=>"descMetadata", :blob=>desc_metadata_xml.read)    
    jp2_content = fixture("sample_object/Feigenbaum_00009503_0001.jp2")
    jp2_ds = ActiveFedora::Datastream.new(:dsid=>"Feigenbaum_00009503_0001.jp2", :label=>"Feigenbaum_00009503_0001.jp2", :blob=>jp2_content, :controlGroup=>"M", :mimeType=>"image/jp2")    
    jp2_ds.attributes["mimeType"] = "image/jp2" # This is a hack to deal with a bug in the way activefedora's datastream instance initializer handles mime types 
    [properties_ds, ext_properties_ds, desc_metadata_ds, jp2_ds].each {|x| @sample_object.add_datastream(x)}
    @sample_object.save
  end
  
  after(:all) do
    escaped_pid = @sample_object.pid.gsub(/(:)/, '\\:')
    @sample_object.delete
    ActiveFedora::SolrService.instance.conn.delete(escaped_pid)
  end
  
  before(:each) do
    @replicator = Shelver::Replicator.new
  end
  
  it "should be a kind of Shelver" do
    @replicator.should be_instance_of(Shelver::Replicator)
  end

  it "should get its solr and fedora locations from replicator.yml" do
    @replicator.dest_repo.should be_instance_of(Fedora::Repository)
    @replicator.dest_repo.fedora_url.to_s.should == @replicator_configs["destination"]["fedora"]["url"]    
    ActiveFedora.fedora.fedora_url.to_s.should == @replicator_configs["source"]["fedora"]["url"]
    #@replicator.source_repo.base_url.should == @replicator_configs["source"]["fedora"]["url"]
  end

  
  describe "replicate_object" do
    it "should load Document from source repo and call create_stub, passing in the loaded Document" do
      pending
      mock_document =  mock("Document")
      mock_document.stubs(:pid)
      mock_document.stubs(:label)
      Document.expects(:load_instance).with("foo:test").returns(mock_document)
      @replicator.expects(:create_stub).with(mock_document)
      @replicator.replicate_object("foo:test")
    end
  end
  
  describe "replicate_objects" do
    it "should retrieve pids and pass each pid to replicate_object" do
      pids = ["pid1", "pid2", "pid3"]
      Shelver::Repository.expects(:get_pids).returns( pids )
      pids.each {|p| @replicator.expects(:replicate_object).with(p) }
      @replicator.replicate_objects
    end
  end
  
  describe "create_stub" do
    it "should create a new fedora object with copies of the necessary source document datastreams (descMetadata[X], properties[X], extProperties[E]) and stick in a placeholder for the canonical JP2" do 
      pending
      stub_object = mock("stub object")
      Fedora::FedoraObject.expects(:new).with(:pid=>@sample_object.pid).returns(stub_object)
      @replicator.dest_repo.expects(:save).with(stub_object)
      ["properties", "extProperties", "descMetadata"].each do |ds_name|
        ds = @sample_object.datastreams[ds_name]
        ds.expects(:new_object=).with(true)
        ds.expects(:blob=) # ds.content
        @replicator.dest_repo.expects(:save).with(ds)
      end   
      # test for the placeholder jp2  
      mock_jp2 = mock("jp2" )
      [:new_object=,:control_group=,:blob=,:content].each {|m| mock_jp2.expects(m) }
      # mock_jp2.expects(:new_object=)
      # mock_jp2.expects(:control_group=)
      #,:control_group=,:blob,:content)
      @replicator.expects(:downloadables).returns(mock_jp2)
      @replicator.dest_repo.expects(:save).with(mock_jp2)
      @replicator.create_stub(@sample_object)
    end
    # create an empty object in destination repo with same pid as original object
    # add datastreams to the new object in the destination repo
  end

end