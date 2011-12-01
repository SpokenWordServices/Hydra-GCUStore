class ModsJournalArticle < ObjectMods

  set_terminology do |t|
    t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/standards/mods/v3/mods-3-4.xsd")

    t.title_info(:path=>"titleInfo") {
      t.main_title(:path=>"title", :label=>"title", :index_as=>[:facetable])
      t.language(:index_as=>[:facetable],:path=>{:attribute=>"lang"})
    } 
    t.title(:proxy=>[:title_info, :main_title]) 
    t.language{
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
      t.affiliation
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
      t.affiliation(:index_as=>[:facetable])
    }
    t.genre(:path=>'genre')
    t.origin_info(:path=>'originInfo') {
      t.date_issued(:path=>'dateIssued')
      t.publisher
    }
    t.related_item_private_object(:path=>'relatedItem', :attributes=>{:ID=>'privateObject'}) {
      t.private_object_id(:path=>'identifier', :attributes=>{:type=>'fedora'})
    }
    #relatedItem type="otherVersion"
    t.journal(:path=>'relatedItem', :attributes=>{:type=>'otherVersion'}) {
       t.title_info(:path=>"titleInfo") {
         t.main_title(:path=>"title", :label=>"title")
       }
       t.origin_info(:path=>"originInfo") {
        t.publisher
        t.date_issued(:path=>"dateIssued")
       }
       t.issn_print(:path=>'identifier', :attributes=>{:type=>'issn', :displayLabel=>'print'})
       t.issn_electronic(:path=>'identifier', :attributes=>{:type=>'issn', :displayLabel=>'electronic'})
       t.doi(:path=>'identifier', :attributes=>{:type=>'doi'})
       t.part {
         t.volume(:path=>'detail', :attributes=>{:type=>'volume'}, :default_content_path=>"number")
         t.issue(:path=>'detail', :attributes=>{:type=>'issue'}, :default_content_path=>"number")
         t.pages(:path=>'extent', :attributes=>{:unit=>'pages'}) {
           t.start
           t.end 
         }
         t.start_page(:proxy=>[:pages, :start])
         t.end_page(:proxy=>[:pages, :end])
         t.publication_date(:path=>"date")
       }
       t.note_restriction(:path=>'note', :attributes=>{:type=>'restriction'})
    }
    t.peer_reviewed(:path=>'note', :attributes=>{:type=>'peerReviewed'})
    t.physical_description(:path=>"physicalDescription") {
      t.extent
      t.mime_type(:path=>"internetMediaType")
      t.digital_origin(:path=>"digitalOrigin")
    }    
    t.rights(:path=>"accessCondition", :attributes=>{:type=>"useAndReproduction"})
    
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
             xml.titleInfo(:lang=>"") {
               xml.title
             }
             xml.name(:type=>"personal") {
               xml.namePart
               xml.role {
                 xml.roleTerm(:type=>"text")
               }
             }
             xml.genre
             xml.language {
               xml.languageTerm(:type=>"text")
               xml.languageTerm(:authority=>"iso639-2b", :type=>"code")
             }
             xml.abstract
             xml.subject(:authority=>"UoH") {
               xml.topic
             }
             xml.identifier(:type=>"fedora")
             xml.relatedItem(:type=>"otherVersion") {
               xml.titleInfo {
                 xml.title
               }
               xml.issn_print(:path=>"identifier", :type=>"issn", :displayLabel=>"print")
               xml.issn_electronic(:path=>"identifier", :type=>"issn", :displayLabel=>"electronic")
               xml.doi(:path=>"identifier", :type=>"doi")
               xml.part {
                 xml.detail(:type=>"volume") {
                   xml.number
                 }
                 xml.detail(:type=>"issue") {
                   xml.number
                 }
                 xml.extent(:unit=>"pages") {
                   xml.start
                   xml.end
                 }
                 xml.date
               }
             }
             xml.location {
               xml.url(:usage=>"primary display", :access=>"object in context")
               xml.url(:access=>"raw object")
             }           
             xml.originInfo {
               xml.publisher
               xml.dateIssued
             }
             xml.physicalDescription {
               xml.extent
               xml.internetMediaType
               xml.digitalOrigin 
             }
             xml.accessCondition(:type=>"useAndReproduction")
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
        solr_doc.merge!("object_type_facet"=> "Journal article")
        solr_doc
	end

end
