class ContentMetadata < ActiveFedora::NokogiriDatastream       

  set_terminology do |t|
    t.root(:path=>"contentMetadata", :xmlns=>"http://hydra-collab.hull.ac.uk/schemas/contentMetadata/v1", :schema=>"http://github.com/projecthydra/schemas/tree/v1/contentMetadata.xsd")

   t.resource {
      t.resource_id(:path=>{:attribute=>"id"})
      t.sequence(:path=>{:attribute=>"sequence"})
      t.display_label(:path=>{:attribute=>"displayLabel"})
      t.resource_object_id(:path=>{:attribute=>"objectID"})
      t.resource_ds_id(:path=>{:attribute=>"dsID"})
      t.dissType(:path=>{:attribute=>"dissType"})
      t.file {
        t.file_id(:path=>{:attribute=>"id"})
        t.format(:path=>{:attribute=>"format"})
        t.mime_type(:path=>{:attribute=>"mimeType"})
        t.size(:path=>{:attribute=>"size"})
        t.location
      }
    }
    t.content_url(:proxy=>[:resource,:file,:location])
    t.content_format(:proxy=>[:resource,:file,:format])
    t.content_mime_type(:proxy=>[:resource,:file,:mime_type])
    t.content_size(:proxy=>[:resource,:file,:size])
  
  end
  
   
    # Generates an empty contentMetadata
    def self.xml_template
      builder = Nokogiri::XML::Builder.new do |xml|
      xml.contentMetadata(:type=>"text",:version=>"1.0", "xmlns"=>"http://hydra-collab.hull.ac.uk/schemas/contentMetadata/v1") {
      }
      end
      return builder.doc
    end
    
    # generates a resource template, with the option of filling it out
    # @param [Hash] opts optional values passed in
    # @option opts [String] :sequence the sequence number
    # @option opts [String] :id the resource id
    # @option opts [String] :display_label the dislpayLabel for the resource
    # @option opts [String] :object_id the objectID for the resourc
    # @option opts [String] :file_id the id for the file [default "content"]
    # @option opts [String] :file_size the size of the file
    # @option opts [String] :url the location url of the file
    def self.resource_template(opts={})
      options = {:sequence=>"",:id=>"",:display_label=>"",:object_id=>"",:file_id=>"content",:file_size=>"",:url=>""}
      options.merge!(opts)
      options.merge!({:id=>"Asset #{options[:display_label]}"})
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.resource(:sequence=>options[:sequence],:id=>options[:id],:displayLabel=>options[:display_label],:objectID=>options[:object_id],:dsID=>"content",:dissType=>"genericContent/content") {
          xml.file(:id=>options[:id], :format=>"pdf", :mimeType=>"application/pdf", :size=>options[:file_size]) {
            xml.location(options[:url], :type=>"url")
          }
        }
      end
      return builder.doc.root
    end

    # inserts a resource template, with the option of filling it out
    # @param [Hash] opts optional values passed in
    # @option opts [String] :sequence the sequence number
    # @option opts [String] :id the resource id
    # @option opts [String] :display_label the dislpayLabel for the resource
    # @option opts [String] :object_id the objectID for the resourc
    # @option opts [String] :file_id the id for the file [default "content"]
    # @option opts [String] :file_size the size of the file
    # @option opts [String] :url the location url of the file
    def insert_resource(opts={})
      nodeset = self.find_by_terms(:resource)

      # set the default sequence number unless one is already specified
      unless opts[:sequence]
        opts[:sequence] = nodeset.nil? ? "0" : (nodeset.length + 1).to_s
      end

      node = ContentMetadata.resource_template(opts)

      unless nodeset.nil?
        if nodeset.empty?
          self.ng_xml.root.add_child(node)
          index = 0
        else
          nodeset.after(node)
          index = nodeset.length
        end
        self.dirty = true
      end

      return node, index
    end

    def remove_resource(index)
      self.find_by_terms(:resource)[index.to_i].remove
      self.dirty = true
    end

end
