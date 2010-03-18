#require "active_fedora"
class SaltDocument < ActiveFedora::Base

    has_relationship "parts", :is_part_of, :inbound => true
    
    # These are all the properties that don't quite fit into Qualified DC
    # Put them on the object itself (in the properties datastream) for now.
    has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
      m.field "note", :text  
      m.field "access", :string
      m.field "archivist_tags", :string
      m.field "donor_tags", :string
    end
    
    has_metadata :name => "stories", :type=>ActiveFedora::MetadataDatastream do |m|
      m.field "story", :text
    end
    
    has_metadata :name => "descMetadata", :type => ActiveFedora::QualifiedDublinCoreDatastream do |m|
      # Default :multiple => true
      #
      # on retrieval, these will be pluralized and returned as arrays
      #
      # aimint to use method-missing to support calling methods like
      
      # Setting new Types for dates and text content
      #m.field "creation_date", :string, :xml_node => "date"
      #m.field "abstract", :text, :xml_node => "abstract"
      #m.field "rights", :text, :xml_node => "rights"
      
      # Setting up special named fields
      m.field "subject_heading", :string, :xml_node => "subject", :encoding => "LCSH" 
      m.field "spatial_coverage", :string, :xml_node => "spatial", :encoding => "TGN"
      m.field "temporal_coverage", :string, :xml_node => "temporal", :encoding => "Period"
      m.field "type", :string, :xml_node => "type", :encoding => "DCMITYPE"
    end

    def save
      super
      shelver = Shelver::Shelver.new
      shelver.shelve_object( self )
    end
  

end
