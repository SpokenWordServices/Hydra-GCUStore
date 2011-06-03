class ModsStructuralSet < ObjectMods

  set_terminology do |t|
    t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/standards/mods/v3/mods-3-4.xsd")
    t.title_info(:path=>"titleInfo") {
      t.main_title(:path=>"title", :label=>"title")
    } 
    t.title(:proxy=>[:title_info, :main_title])
    t.genre(:path=>'genre')
    t.origin_info(:path=>'originInfo') {
    	t.publisher
    }
    t.language{
      t.lang_text(:path=>"languageTerm", :attributes=>{:type=>"text"})
      t.lang_code(:index_as=>[:facetable], :path=>"languageTerm", :attributes=>{:type=>"code"})
    }
    t.description(:path=>"abstract")
  
    t.identifier(:path => 'identifier',:attributes=>{:type=>"fedora"})
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
			 xml.typeOfResource (:collection=>"yes")
	         xml.genre
             xml.abstract
             xml.originInfo {
               xml.publisher
             }
             xml.identifier(:type=>"fedora")
             xml.location {
               xml.url(:access=>"raw object")
             } 
             xml.recordInfo {
               xml.recordContentSource
               xml.recordCreationDate(:encoding=>"w3cdtf")
               xml.recordChangeDate(:encoding=>"w3cdtf")
               xml.languageOfCataloging {
                 xml.languageTerm(:authority=>"iso639-2b")  
               }
             }
        }
      end
      return builder.doc
    end    

	def to_solr(solr_doc=Hash.new)
        super(solr_doc)
        solr_doc.merge!("object_type_facet"=> "Structural set")
        solr_doc
	end

end
