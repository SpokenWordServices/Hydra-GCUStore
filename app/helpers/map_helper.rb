require 'lib/hull/gmap_polyline_encoder'
module MapHelper

  #This is will use the coordinates fields...
  def include_google_static_map(document_fedora)
    if !document_fedora.nil?
       get_coordinate_list( get_coordinates_from_document_fedora(document_fedora) )
    end
  end

  def get_coordinates_from_document_fedora(document_fedora)
   #standard place for coordinates is delagated to coordinates variable
   return document_fedora.coordinates
  end   


  def display_map(coordinates)
    
 
  end
  
  def create_polyline( coordinate_list )
    
      Role.find_by_name(r).users.map { |user| user.username }


    #coordinate_list.each {    } 
    #gmap_location_array = coordinate_list.map { |long,lat|   }

    encoder = Hull::GMapPolylineEncoder.new()
    encoder.encode([[-0.451126,53.847057]])
  end


  def get_coordinate_list(coordinate_list)
   #This gets us an array of coords
   coords = coordinate_list.split(" ")

   #Holding array for our array of coordinates
   coordinate_list = []
  
   coords.each do |coordinate|
     values = coordinate.split(",")     
     long = values[0]
     lat = values[1]
     if values.size == 3 then alt = values[2] end
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
