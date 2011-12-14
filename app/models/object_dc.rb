class ObjectDc < ActiveFedora::NokogiriDatastream
	set_terminology do |t|
   t.root(:path=>"dc",:xmlns=>"http://purl.org/dc/elements/1.1/",
											"xmlns:oai_dc"=>"http://www.openarchives.org/OAI/2.0/oai_dc/",
											"xmlns:dc"=>"http://purl.org/dc/elements/1.1/",
           						"xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
           						"xsi:schemaLocation"=>"http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd",
											:schema=>"http://www.openarchives.org/OAI/2.0/oai_dc.xsd")
    t.dc_title(:path=>"title") 
    t.dc_genre(:path=>"type", :xmlns=>"http://purl.org/dc/elements/1.1/")
		t.dc_identifier(:path=>"identifier")
		t.dc_dateIssued(:path=>"date")#, :xmlns=>"http://purl.org/dc/elements/1.1/")
  end
 	# Generates an empty DC datastream
  def self.xml_template
	      builder = Nokogiri::XML::Builder.new do |xml|
        xml.dc("xmlns:oai_dc"=>"http://www.openarchives.org/OAI/2.0/oai_dc/",
								"xmlns:dc"=>"http://purl.org/dc/elements/1.1/",
           			"xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
           			"xsi:schemaLocation"=>"http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd") {
						xml.parent.namespace = xml.parent.namespace_definitions.last #This puts the namespace declaration on the root node...
						xml['dc'].title
						xml['dc'].type_
						xml['dc'].identifier
						xml['dc'].date(Time.now.strftime("%Y-%m-%d"))
        }
      end
      return builder.doc
    end 
end       

