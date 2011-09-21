module ActiveFedora
  module SemanticNode

    # Creates a RELS-EXT datastream for insertion into a Fedora Object
    # @param [String] pid
    # @param [Hash] relationships (optional) @default self.relationships
    # Note: This method is implemented on SemanticNode instead of RelsExtDatastream because SemanticNode contains the relationships array
    def to_rels_ext(pid, relationships=self.relationships)
      starter_xml = <<-EOL
      <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:oai="http://www.openarchives.org/OAI/2.0/">
        <rdf:Description rdf:about="info:fedora/#{pid}">
        </rdf:Description>
      </rdf:RDF>
      EOL
      xml = REXML::Document.new(starter_xml)
      self.outbound_relationships.each do |predicate, targets_array|
        targets_array.each do |target|
          xmlns=String.new
          case predicate
          when :has_model, "hasModel", :hasModel
            xmlns="info:fedora/fedora-system:def/model#"
            begin
              rel_predicate = self.class.predicate_lookup(predicate,xmlns)
            rescue UnregisteredPredicateError
              xmlns = nil
              rel_predicate = nil
            end
          else
            xmlns="info:fedora/fedora-system:def/relations-external#"
            begin
              rel_predicate = self.class.predicate_lookup(predicate,xmlns)
            rescue UnregisteredPredicateError
              xmlns = nil
              rel_predicate = nil
            end
          end
          
          unless xmlns && rel_predicate
            rel_predicate, xmlns = self.class.find_predicate(predicate)
          end
          #puts ". #{predicate} #{target} #{xmlns}"
          literal = URI.parse(target).scheme.nil? || predicate == :oai_item_id
          if predicate == :oai_item_id
            xml.root.elements["rdf:Description"].add_element('oai:' +rel_predicate).add_text(target)
          elsif literal
            xml.root.elements["rdf:Description"].add_element(rel_predicate, {"xmlns" => "#{xmlns}"}).add_text(target)
          else
            xml.root.elements["rdf:Description"].add_element(rel_predicate, {"xmlns" => "#{xmlns}", "rdf:resource"=>target})
          end
        end
      end
      xml.to_s
    end

  end
end
