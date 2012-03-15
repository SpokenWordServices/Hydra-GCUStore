require 'lib/hull/gmap_polyline_encoder'
module MapHelper

  #This is will use the coordinates fields...
  def include_google_static_map(document_fedora)
    if !document_fedora.nil?
       encoded_polyline =  create_polyline(get_coordinate_list( get_coordinates_from_document_fedora(document_fedora) ) )    
       display_map(encoded_polyline)       
    end
  end

  def get_coordinates_from_document_fedora(document_fedora)
   #standard place for coordinates is delagated to coordinates variable
   return document_fedora.coordinates.to_s
  end   

  def display_map(encoded_polyline)
          
      map_size = "300x300"
      fillcolor = "0xAA000033"
      color = "0xFFFFFF00"

      debugger
      
      google_maps_url = "https://maps.googleapis.com/maps/api/staticmap?sensor=false&size=" + map_size + "&path=fillcolor:" + fillcolor + "%7Ccolor:" + color + "%7Cenc:" + encoded_polyline[:points] + "" 

      map = <<-EOS
        <img src="#{google_maps_url}" alt="Map">
      EOS

     map.html_safe
 
  end
  
  def create_polyline( coordinate_list )
    
    data = []
    coordinate_list.each { |coord|  data << [coord.latitude, coord.longitude]  } 
   
    encoder = Hull::GMapPolylineEncoder.new()
    encoder.encode(data)
  end


  def get_coordinate_list(coordinates)

   #This gets us an array of coords
   coords = coordinates.split(" ")

   #Holding array for our array of coordinates
   coordinate_list = []
  
   coords.each do |coordinate|
     values = coordinate.split(",")     
     long = values[0].to_f
     lat = values[1].to_f
     if values.size == 3 then alt = values[2].to_f end
     coordinate_list << Coordinate.new(long, lat, alt)
   end

   return coordinate_list  
  end


end


class Coordinate
  attr_accessor :longitude, :latitude, :altitude

 def initialize(longitude, latitude, altitude)
   @longitude = !longitude.nil? ? longitude : 0.000000
   @latitude = !latitude.nil? ? latitude : 0.000000
   @altitude = !altitude.nil? ? altitude : 0.00
 end 


 def lat_long_alt_str
  return @latitude + "," + @longitude + "," + @altitude
 end

 def long_late_alt_str
  return @longitude + "," + @latitude + "," + @altitude
 end

end
