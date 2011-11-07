module Hull
  extend ActiveSupport::Autoload

puts "*****\n\n*****INSIDE HULL"
  #autoload :HullAccessControlEnforcement
end
Dir[File.join(File.dirname(__FILE__), "hull", "*.rb")].each {|f| puts "*****#{f}"; require f}
puts "Done ***"

#Dir[File.join(File.dirname(__FILE__), "narm", "*.rb")].each {|f| require f}


