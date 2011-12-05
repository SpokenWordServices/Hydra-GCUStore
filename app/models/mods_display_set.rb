class ModsDisplaySet < ObjectMods

  set_terminology do |t|
    t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/standards/mods/v3/mods-3-4.xsd")
    t.title_info(:path=>"titleInfo") {
      t.main_title(:path=>"title", :label=>"title")
    } 
    t.title(:proxy=>[:mods, :title_info, :main_title]) 
    t.genre(:path=>'genre')
    t.origin_info(:path=>'originInfo') {
			t.publisher
   		 t.date_issued(:path=>"dateIssued")
    }
    t.language{
      t.lang_text(:path=>"languageTerm", :attributes=>{:type=>"text"})
      t.lang_code(:index_as=>[:facetable], :path=>"languageTerm", :attributes=>{:type=>"code"})
    }
    t.description(:path=>"abstract")
    t.subject(:path=>"subject", :attributes=>{:authority=>"UoH"}) {
     t.topic(:index_as=>[:facetable])
		 t.geographic
		 t.temporal
    }  
    t.identifier(:path => 'identifier',:attributes=>{:type=>"fedora"})

		t.location {
			t.primary_display(:path=>"url", :attributes=>{:access=>"object in context", :usage=>"primary display" })
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
             xml.titleInfo {
               xml.title
             }
			 			 xml.typeOfResource("text", :collection=>"yes") 
	         	 xml.genre "Display set"
             xml.abstract
						 xml.subject(:authority=>"UoH") {
               xml.topic
 							 xml.geographic
							 xml.temporal
             }
             xml.originInfo {
							 xml.publisher "The University of Hull"
             	 xml.dateIssued(Time.now.strftime("%Y-%m-%d"))
             }
             xml.identifier(:type=>"fedora")
             xml.location {
               xml.url(:access=>"raw object")
             } 
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
        solr_doc.merge!("object_type_facet"=> "Display set")
        solr_doc
	end

end
