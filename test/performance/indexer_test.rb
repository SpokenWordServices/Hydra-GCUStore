require 'test_helper'
require 'performance_test_help'

class ShelverTest < ActionController::PerformanceTest
  
  def setup
  end
  
  def test_shelve_large_object
    @shelver = Shelver::Shelver.new
    @shelver.shelve_object("druid:cs409mn9638")
    obj = Document.load_instance("druid:cs409mn9638")
  end
  
end
