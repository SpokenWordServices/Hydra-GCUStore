class HydraDatasetDs < NokogiriDatastream
  
  set_terminology do |t|
    t.root(:path=>"hydraDataset", :xmlns=>"http://www.loc.gov/mods/v3")
    t.completeness
    t.interval
    t.data_type
    t.timespan_start
    t.timespan_end
    t.gps
    t.region    
    t.site    
    t.ecosystem    
    t.grant {
      t.organization
      t.number
    }
    t.data_quality
    t.contact_name
    t.contact_email
  end
  
  def self.xml_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.hydraDataset(:xmlns=>"http://yourmediashelf.com/schemas/hydra-dataset/v0") {
        xml.completeness
        xml.interval
        xml.data_type
        xml.timespan_start
        xml.timespan_end
        xml.gps
        xml.region    
        xml.site    
        xml.ecosystem    
        xml.grant {
          xml.organization
          xml.number
        }
        xml.data_quality
        xml.contact_name
        xml.contact_email
      }   
    return builder.doc
  end
  
  # Generates a new Person node
  def self.grant_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.grant {
        xml.organization
        xml.number
      }
    end
    return builder.doc.root
  end
  
  # Inserts a new grant into the xml document
  # We should probably write a helper that auto-generates this for you.
  def insert_grant
    node = Hydra::HydraDatasetDs.grant_template
    nodeset = self.find_by_terms(:grant)
    
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

end