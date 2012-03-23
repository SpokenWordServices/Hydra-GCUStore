class ModsDataset < ObjectMods

  set_terminology do |t|
    t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/standards/mods/v3/mods-3-4.xsd")

    t.title_info(:path=>"titleInfo") {
      t.main_title(:path=>"title", :label=>"title", :index_as=>[:facetable])
      t.part_name(:path=>"partName")
    } 
   
    # Description is stored in the 'abstract' field 
    t.description(:path=>"abstract")   
   
    t.subject(:path=>"subject", :attributes=>{:authority=>"UoH"}) {
     t.topic(:index_as=>[:facetable])
     t.temporal
     t.geographic
    }
		t.location_subject(:path=>"subject", :attributes=>{:ID=>"location"}) {
      t.display_label(:path=>{:attribute=>"displayLabel"}, :namespace_prefix => nil)
      t.coordinates_type(:path=>"topic")
			t.cartographics {
				t.coordinates
			}
		}
    t.type_of_resource(:path=>"typeOfResource")
    t.genre
    
    # This is a mods:name.  The underscore is purely to avoid namespace conflicts.
    t.name_ {
      # this is a namepart
      t.namePart(:type=>:string, :label=>"generic name")
      t.role(:ref=>[:role])
    }
    # lookup :person, :first_name        
    t.person(:ref=>:name, :attributes=>{:type=>"personal"}, :index_as=>[:facetable])
    t.organization(:ref=>:name, :attributes=>{:type=>"corporate"}, :index_as=>[:facetable])
    t.conference(:ref=>:name, :attributes=>{:type=>"conference"}, :index_as=>[:facetable])
    t.role {
      t.text(:path=>"roleTerm",:attributes=>{:type=>"text"})
      t.code(:path=>"roleTerm",:attributes=>{:type=>"code"})
    }
    
		#corporate_name/personal_name created to provide facets without an appended roleTerm
    t.corporate_name(:path=>"name", :attributes=>{:type=>"corporate"}) {
      t.part(:path=>"namePart",:index_as=>[:facetable])
    }
    t.personal_name(:path=>"name", :attributes=>{:type=>"personal"}) {
      t.part(:path=>"namePart",:index_as=>[:facetable])
    }
    t.origin_info(:path=>"originInfo") {
      t.publisher
 			t.date_issued(:path=>"dateIssued")
      t.date_valid(:path=>"dateValid", :attributes=>{:encoding=>'iso8601'})    
    } 
    t.language {
      t.lang_text(:path=>"languageTerm", :attributes=>{:type=>"text"})
      t.lang_code(:index_as=>[:facetable], :path=>"languageTerm", :attributes=>{:type=>"code"})
    }
    t.role {
      t.text(:path=>"roleTerm",:attributes=>{:type=>"text"})
    }
    t.related_private_object(:path=>"relatedItem", :attributes=>{:ID=>"privateObject"}) {
			t.private_object_id(:path=>"identifier", :attributes=>{:type=>"fedora"})
    }
    t.web_related_item(:path=>"relatedItem", :attributes=>{:ID=>"relatedMaterials"})	{
			t.location {
	  		t.primary_display(:path=>"url", :attributes=>{:access=>"object in context", :usage=>"primary display" })
	  	}
		}
		t.identifier(:path=>"identifier", :attributes=>{:type=>"fedora"})
    t.doi(:path=>'identifier', :attributes=>{:type=>'doi'})
    t.see_also(:path=>"note", :attributes=>{:type=>"seeAlso"})
    t.rights(:path=>"accessCondition", :attributes=>{:type=>"useAndReproduction"})
		t.location {
	  	t.primary_display(:path=>"url", :attributes=>{:access=>"object in context", :usage=>"primary display" })
	  	t.raw_object(:path=>"url", :attributes=>{:access=>"raw object"})
 		}
    t.physical_description(:path=>"physicalDescription") {
      t.extent
      t.mime_type(:path=>"internetMediaType")
      t.digital_origin(:path=>"digitalOrigin")
    }
    t.admin_note(:path=>"note", :attributes=>{:type=>"admin"})
    t.additional_notes(:path=>"note", :attributes=>{:type=>"additionalNotes"})    
    t.citation(:path=>"note", :attributes=>{:type=>"citation"})
    t.software(:path=>"note", :attributes=>{:type=>"software"})
    
    # Proxies
    t.title(:proxy=>[:mods, :title_info, :main_title])
    t.version(:proxy=>[:mods, :title_info, :part_name])
    t.date_issued(:proxy=>[:origin_info, :date_issued])
    t.coordinates(:proxy=>[:location_subject, :cartographics, :coordinates])
    t.related_web_item(:proxy=>[:web_related_item, :location, :primary_display])
    t.extent(:proxy=>[:physical_description, :extent])
    t.publisher(:proxy=>[:origin_info, :publisher])
  
    t.lang_text(:proxy=>[:language, :lang_text])
    t.lang_code(:proxy=>[:language, :lang_code])
    t.digital_origin(:proxy=>[:physical_description, :digital_origin])
    t.topic_tag(:proxy=>[:subject, :topic])
    t.geographic_tag(:proxy=>[:subject, :geographic])
    t.temporal_tag(:proxy=>[:subject, :temporal])
    t.coordinates(:proxy=>[:location_subject, :cartographics, :coordinates])
    t.coordinates_type(:proxy=>[:location_subject, :coordinates_type])
    t.coordinates_title(:proxy=>[:location_subject, :display_label])

	  t.record_info(:path=>"recordInfo") {
    	t.record_creation_date(:path=>"recordCreationDate", :attributes=>{:encoding=>"w3cdtf"})
      t.record_change_date(:path=>"recordChangeDate", :attributes=>{:encoding=>"w3cdtf"})
    }
  end
  
     # accessor :title, :term=>[:mods, :title_info, :main_title]
    
    # Generates an empty Mods Article (used when you call ModsArticle.new without passing in existing xml)
    def self.xml_template
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.mods(:version=>"3.4", "xmlns:xlink"=>"http://www.w3.org/1999/xlink",
           "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
           "xmlns"=>"http://www.loc.gov/mods/v3",
           "xsi:schemaLocation"=>"http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-4.xsd") {
             xml.titleInfo(:lang=>"") {
               xml.title
             }
             xml.name(:type=>"personal") {
               xml.namePart
               xml.role {
                 xml.roleTerm("creator", :type=>"text")
               }
             }
             xml.typeOfResource
             xml.genre "Dataset"
             xml.language {
               xml.languageTerm("English", :type=>"text")
               xml.languageTerm("eng", :authority=>"iso639-2b", :type=>"code")
             }
             xml.abstract
             xml.subject(:authority=>"UoH") {
               xml.topic
             }
             xml.originInfo {
               xml.publisher
               xml.dateOrigin
             }
             xml.physicalDescription {
               xml.extent
               xml.internetMediaType
               xml.digitalOrigin "born digital"
             }
						 xml.identifier(:type=>"fedora")
             xml.location {
               xml.url(:usage=>"primary display", :access=>"object in context")
               xml.url(:access=>"raw object")
             }
             xml.accessCondition(:type=>"useAndReproduction")
             xml.recordInfo {
               xml.recordContentSource "The University of Hull"
               xml.recordCreationDate(Time.now.strftime("%Y-%m-%d"), :encoding=>"w3cdtf")
               xml.recordChangeDate(:encoding=>"w3cdtf")
               xml.languageOfCataloging {
                 xml.languageTerm("eng", :authority=>"iso639-2b")  
               }
             }
        }
      end
      return builder.doc
    end      
	
	def to_solr(solr_doc=Hash.new)
   super(solr_doc)
   solr_doc.merge!("object_type_facet"=> "Dataset")
   solr_doc
	end

end
