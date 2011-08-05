class ModsGenericContent < ObjectMods

  set_terminology do |t|
    t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/standards/mods/v3/mods-3-2.xsd")

    t.title_info(:path=>"titleInfo") {
      t.main_title(:path=>"title", :label=>"title") 
    } 
    t.title(:proxy=>[:title_info, :main_title]) 
   
    # Description is stored in the 'abstract' field 
    t.description(:path=>"abstract")   
   
    t.subject(:path=>"subject", :attributes=>{:authority=>"UoH"}) {
     t.topic(:index_as=>[:facetable])
    }
		t.location_subject (:path=>"subject") {
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
    } 
    t.language {
      t.lang_text(:path=>"languageTerm", :attributes=>{:type=>"text"})
      t.lang_code(:index_as=>[:facetable], :path=>"languageTerm", :attributes=>{:type=>"code"})
    }
    t.role {
      t.text(:path=>"roleTerm",:attributes=>{:type=>"text"})
    }
    t.related_private_object(:path=>"relatedItem", :attributes=>{:type=>"privateObject"}) {
			t.private_object_id(:path=>"identifier", :attributes=>{:type=>"fedora"})
    }
    t.web_related_item(:path=>"relatedItem")	{
			t.location {
	  		t.primary_display(:path=>"url", :attributes=>{:access=>"object in context", :usage=>"primary display" })
	  	}
		}
		t.identifier(:path=>"identifier", :attributes=>{:type=>"fedora"})
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
                 xml.roleTerm(:authority=>"marcrelator", :type=>"text")
               }
             }
             xml.genre(:authority=>"marcgt")
             xml.language {
               xml.languageTerm(:type=>"text")
               xml.languageTerm(:authority=>"iso639-2b", :type=>"code")
             }
             xml.abstract
             xml.subject {
               xml.topic
             }
             xml.identifier(:type=>"fedora")
             xml.originInfo {
               xml.publisher
               xml.dateIssued
             }
             xml.physicalDescription {
               xml.extent
               xml.internetMediaType
               xml.digitalOrigin 
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
