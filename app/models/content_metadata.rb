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
        xml.resource(:sequence=>"1", :id=>"", :displayLabel=>"", :objectID=>"", :dsID=>"content", :dissType=>"genericContent/content") {
          xml.file(:id=>"", :format=>"pdf", :mimeType=>"application/pdf", :size=>"") {
            xml.location(:type=>"url")
          }
        }
      }
      end
      return builder.doc
    end      
end
