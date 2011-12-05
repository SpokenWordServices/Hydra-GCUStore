class ModsUketd < ObjectMods
 
  set_terminology do |t|
    t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/standards/mods/v3/mods-3-2.xsd")

    t.title_info(:path=>"titleInfo") {
      t.main_title(:path=>"title", :label=>"title")
      t.language(:index_as=>[:facetable],:path=>{:attribute=>"lang"})
    } 
    t.title(:proxy=>[:mods, :title_info, :main_title]) 

    t.language(:path=>"language"){
      t.lang_text(:path=>"languageTerm", :attributes=>{:type=>"text"})
      t.lang_code(:index_as=>[:facetable], :path=>"languageTerm", :attributes=>{:type=>"code"})
    }

    t.abstract
       
    t.subject(:path=>"subject", :attributes=>{:authority=>"UoH"}) {
      t.topic(:index_as=>[:facetable])
    }
    t.topic_tag(:index_as=>[:facetable],:path=>"subject", :default_content_path=>"topic") 

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
    t.genre(:path=>'genre')
	t.type_of_resource(:path=>"typeOfResource")
    t.qualification_level(:path=>"note", :attributes=>{:type=>"qualificationLevel"})
    t.qualification_name(:path=>"note", :attributes=>{:type=>"qualificationName"})
    t.origin_info(:path=>'originInfo') {
      t.date_issued(:path=>'dateIssued')
      t.publisher
    }
    t.physical_description(:path=>"physicalDescription") {
      t.extent
      t.mime_type(:path=>"internetMediaType")
      t.digital_origin(:path=>"digitalOrigin")
    }
    t.rights(:path=>"accessCondition", :attributes=>{:type=>"useAndReproduction"})

	t.identifier(:path=>"identifier", :attributes=>{:type=>"fedora"})

	t.related_private_object(:path=>"relatedItem", :attributes=>{:type=>"privateObject"}) {
	  t.private_object_id(:path=>"identifier", :attributes=>{:type=>"fedora"})
    }
  t.rights(:path=>"accessCondition", :attributes=>{:type=>"useAndReproduction"})
	t.location {
	  t.primary_display(:path=>"url", :attributes=>{:access=>"object in context", :usage=>"primary display" })
	  t.raw_object(:path=>"url", :attributes=>{:access=>"raw object"})
    }

	t.grant_number(:path=>"identifier", :attributes=>{:type=>"grantNumber"})

  end
  
    # accessor :title, :term=>[:mods, :title_info, :main_title]
    
    # Generates an empty Mods Article (used when you call ModsArticle.new without passing in existing xml)
    def self.xml_template
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.mods(:version=>"3.3", "xmlns:xlink"=>"http://www.w3.org/1999/xlink",
           "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
           "xmlns"=>"http://www.loc.gov/mods/v3",
           "xsi:schemaLocation"=>"http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd") {
             xml.titleInfo {
               xml.title "Title goes here"
             }
             xml.name(:type=>"personal") {
               xml.namePart("Author goes here")
               xml.role {
                 xml.roleTerm("creator",:type=>"text")
               }
             }
					 	 xml.typeOfResource "text"
             xml.genre "Thesis or dissertation"
						 xml.originInfo {
               xml.publisher
               xml.dateIssued
             }
             xml.language {
               xml.languageTerm(:type=>"text")
               xml.languageTerm(:authority=>"iso639-2b", :type=>"code")
             }
 						 xml.physicalDescription {
               xml.extent
               xml.mediaType
               xml.digitalOrigin "born digital"
             }
             xml.abstract
             xml.subject(:authority=>"UoH") {
               xml.topic "Subject topic goes here"
             }
             xml.identifier(:type=>"fedora")
						 xml.location {
               xml.url(:usage=>"primary display", :access=>"object in context")
               xml.url(:access=>"raw object")
             }
			 			 xml.identifier(:type=>"grantNumber")
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
        solr_doc.merge!("object_type_facet"=> "Thesis or dissertation")
        solr_doc
   end

end
