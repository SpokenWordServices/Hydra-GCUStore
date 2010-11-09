class HydraDatasetDs < ActiveFedora::NokogiriDatastream 
  
  set_terminology do |t|
    t.root(:path=>"hydraDataset", :xmlns=>"http://yourmediashelf.com/schemas/hydra-dataset/v0")
    t.completeness
    t.completed
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
    t.right_to_deposit
    t.notification_email
    t.license
    t.data_quality
    t.contact_name
    t.contact_email
  end
  
  def self.xml_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.hydraDataset(:xmlns=>"http://yourmediashelf.com/schemas/hydra-dataset/v0") {
        xml.completeness
        xml.completed
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
        xml.right_to_deposit
        xml.notification_email
        xml.license        
        xml.data_quality
        xml.contact_name
        xml.contact_email
      }   
    end

    return builder.doc
  end
  
  # Generates a new Grant node
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
    node = self.class.grant_template
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

  # Remove the grant entry identified by @index
  def remove_grant(index)
    self.find_by_terms({:grant=>index.to_i}).first.remove
    self.dirty = true
  end
  
  def self.right_to_deposit_choices
    ["Select...",
     "I am the owner of this dataset and am authorized to deposit it",
     "I am working on behalf of the owner, who has authorized me to deposit it."
    ]
  end

  def self.embargo_choices
    [
     ["No embargo: data can be published immediately", Date.today.to_s("Y-m-D")],
     ["Embargo for 6 months from date of deposit", (Date.today+6.months).to_s("Y-m-D")],
     ["Embargo for 1 year from date of deposit", (Date.today+1.year).to_s("Y-m-D")],
     ["Embargo for 2 years from date of deposit", (Date.today+2.years).to_s("Y-m-D")],    
    ]
  end

  def self.completed_choices
    ["Time Series",
     "Snapshot / Sample"
    ]
  end

  
  def self.interval_choices
    ["Monthly",
     "Quarterly",
     "Semi-annually",
     "Annually",
     "Irregular"
    ]
  end
  
  def self.data_type_choices
    ["transect",
     "observation",
     "data logging",
     "remote sensing"]
  end

end