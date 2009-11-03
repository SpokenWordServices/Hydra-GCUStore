require 'rubygems'
gem 'ruby-fedora'
gem 'solr-ruby'
module ActiveFedora #:nodoc:
  VERSION='1.0.9'
end

SOLR_DOCUMENT_ID = "id" unless defined?(SOLR_DOCUMENT_ID)
ENABLE_SOLR_UPDATES = true unless defined?(ENABLE_SOLR_UPDATES)

require 'ruby-fedora'
require 'active_fedora/base.rb'
require 'active_fedora/content_model.rb'
require 'active_fedora/datastream.rb'
require 'active_fedora/fedora_object.rb'
require 'active_fedora/metadata_datastream.rb'
require 'active_fedora/model.rb'
require 'active_fedora/property.rb'
require 'active_fedora/qualified_dublin_core_datastream.rb'
require 'active_fedora/relationship.rb'
require 'active_fedora/rels_ext_datastream.rb'
require 'active_fedora/semantic_node.rb'
require 'active_fedora/solr_service.rb'


if ![].respond_to?(:count)
  class Array
    puts "active_fedora is Adding count method to Array"
      def count(&action)
        count = 0
         self.each { |v| count = count + 1}
  #      self.each { |v| count = count + 1 if action.call(v) }
        return count
      end
  end
end

# module ActiveFedora
#   class ServerError < Fedora::ServerError; end # :nodoc:
# end

