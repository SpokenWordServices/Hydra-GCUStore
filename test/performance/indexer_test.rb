require 'test_helper'
require 'performance_test_help'

class SolrizerTest < ActionController::PerformanceTest
  
  def setup
  end
  
  def test_solrize_large_object
    @solrizer = Solrizer::Solrizer.new
    @solrizer.solrize("druid:cs409mn9638")
    obj = Document.load_instance("druid:cs409mn9638")
  end
  
end
