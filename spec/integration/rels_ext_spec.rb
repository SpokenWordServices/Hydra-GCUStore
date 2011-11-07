require 'spec_helper'

describe "#from_xml" do
  it "should handle un-mapped literals" do
    xml = "
            <foxml:datastream ID=\"RELS-EXT\" STATE=\"A\" CONTROL_GROUP=\"X\" VERSIONABLE=\"true\" xmlns:foxml=\"info:fedora/fedora-system:def/foxml#\">
            <foxml:datastreamVersion ID=\"RELS-EXT.0\" LABEL=\"\" CREATED=\"2011-09-20T19:48:43.714Z\" MIMETYPE=\"text/xml\" SIZE=\"622\">
              <foxml:xmlContent>
              <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:oai=\"http://www.openarchives.org/OAI/2.0/\">
                <rdf:Description rdf:about=\"info:fedora/changeme:3489\">
                  <oai:itemID>oai:hull.ac.uk:hull:2708</oai:itemID>
                </rdf:Description>
              </rdf:RDF>
            </foxml:xmlContent>
          </foxml:datastreamVersion>\n</foxml:datastream>\n"
    doc = Nokogiri::XML::Document.parse(xml)
    new_ds = ActiveFedora::RelsExtDatastream.new
    ActiveFedora::RelsExtDatastream.from_xml(new_ds,doc.root)
    new_ext = new_ds.to_rels_ext('changeme:3489')
    new_ext.should match "<oai:itemID>oai:hull.ac.uk:hull:2708</oai:itemID>"
    
  end
end

