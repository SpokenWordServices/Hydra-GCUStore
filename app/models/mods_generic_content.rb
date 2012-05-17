class ModsGenericContent < ObjectMods

  set_terminology do |t|
    t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", "xmlns:xlink"=>"http://www.w3.org/1999/xlink", :schema=>"http://www.loc.gov/standards/mods/v3/mods-3-2.xsd")

    t.title_info(:path=>"titleInfo") {
      t.main_title(:path=>"title", :label=>"title", :index_as=>[:facetable])
      t.sub_title(:path=>"subTitle")
    } 
   
    # Description is stored in the 'abstract' field 
    t.description(:path=>"abstract")  
    t.description_note (:path=>"note", :attributes=>{:type=>"description"})
 
   
    # Take all subjects here - can split them later adding eg  :attributes=>{:authority=>"lcsh"}
    t.subject(:path=>"subject") {
     t.topic(:index_as=>[:facetable])
     t.temporal
     t.geographic
    }
		t.location_subject(:path=>"subject") {
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
    t.see_also(:path=>"note", :attributes=>{:type=>"seeAlso"})
    t.rights_label(:path=>"accessCondition/@displayLabel")

    # Catch missing namespace
    t.rights_url(:path=>"accessCondition/@xlink:href")


    t.rights(:path=>"accessCondition", :attributes=>{:type=>"use and reproduction"})
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
    t.description_note (:path=>"note", :attributes=>{:type=>"content"})
    
    # Proxies
    t.title(:proxy=>[:mods, :title_info, :main_title]) 
    t.sub_title(:proxy=>[:mods, :title_info, :sub_title])
    t.date_valid(:proxy=>[:origin_info, :date_valid])
    t.coordinates(:proxy=>[:location_subject, :cartographics, :coordinates])
    t.related_item(:proxy=>[:web_related_item, :location, :primary_display])
    t.extent(:proxy=>[:physical_description, :extent])
    t.publisher(:proxy=>[:origin_info, :publisher])
    
    t.lang_text(:proxy=>[:language, :lang_text])
    t.lang_code(:proxy=>[:language, :lang_code])
    t.digital_origin(:proxy=>[:physical_description, :digital_origin])
    t.topic_tag(:proxy=>[:subject, :topic])
    t.geographic_tag(:proxy=>[:subject, :geographic])
    t.temporal_tag(:proxy=>[:subject, :temporal])

	  t.record_info(:path=>"recordInfo") {
    	t.record_creation_date(:path=>"recordCreationDate", :attributes=>{:encoding=>"w3cdtf"})
      t.record_change_date(:path=>"recordChangeDate", :attributes=>{:encoding=>"w3cdtf"})
   }
  end
  
     # accessor :title, :term=>[:mods, :title_info, :main_title]
    
    # Generates an empty Mods Article (used when you call ModsArticle.new without passing in existing xml)
    def self.xml_template
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.mods(:version=>"3.3", "xmlns:xlink"=>"http://www.w3.org/1999/xlink",
           "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
           "xmlns"=>"http://www.loc.gov/mods/v3",
           "xsi:schemaLocation"=>"http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd") {
             xml.titleInfo(:lang=>"") {
               xml.title
             }
             xml.name(:type=>"personal") {
               xml.namePart
               xml.role {
                 xml.roleTerm("Creator", :type=>"text")
               }
             }
             xml.typeOfResource
             xml.genre
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
               xml.dateValid(:encoding=>"iso8601")
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
				facet_text = ""
				begin
					#If the field doesn't exist, it throws an exception...
					facet_text = self.get_values(:genre)[0].to_s.length > 0 ? self.get_values(:genre)[0].to_s : "Generic content"
				rescue
					facet_text = "Generic content"
				end				
				solr_doc.merge!("object_type_facet"=> facet_text)
        solr_doc
	end

end
