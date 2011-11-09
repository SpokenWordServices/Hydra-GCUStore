# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
#require 'spec/autorun'
require 'rspec/rails'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :mocha
  config.color_enabled = true
  config.include Devise::TestHelpers, :type => :controller
end

def fixture(file)
  File.new(File.join(File.dirname(__FILE__), 'fixtures', file))
end

def match_html(html)
  # Match two strings, but don't care about whitespace
  simple_matcher("should match #{html}"){|given| given.strip.gsub(/\s+/,' ').gsub('> <','><') == html.strip.gsub(/\s+/,' ').gsub('> <','><') }
end

def connect_bl_solr
  # @connection = Solr::Connection.new( SHELVER_SOLR_URL, :autocommit => :on )
  if defined?(@index_full_text) && @index_full_text
    url = Blacklight.solr_config['fulltext']['url']
  else
    url = Blacklight.solr_config[:url]
  end

  @bl_solr = Solr::Connection.new(url, :autocommit => :on )
end
