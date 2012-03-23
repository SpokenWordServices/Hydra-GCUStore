require 'lib/hull/gmap_polyline_encoder'
module MapHelper

  def display_google_js_map(coordinates, coordinates_type, coordinates_title, dt_title)
    unless coordinates.nil? || coordinates.empty? 
      coordinates = coordinates.first if coordinates.kind_of? Array

      #We first add the javascripts to the includes (local google_maps.js and Googles API code)   
      content_for :google_maps do
        javascript_include_tag ('google_maps','https://maps.googleapis.com/maps/api/js?key=AIzaSyBon_Xir10TbJNA0vzYJ1cJFZvChVS-dcI&sensor=false')
      end 

       #Add coordinates/coordinates_type/coordinates_title to hidden fields to be read by google_maps.js
       map = <<-EOS
       <dt>#{dt_title}</dt>
        <dd>
          <div id="map_canvas" style="width:500px; height:281px"></div>
        </dd>
       #{hidden_field(:document_fedora, :coordinates, :value => coordinates )}
       #{hidden_field(:document_fedora, :coordinates_type, :value => coordinates_type )}
       #{hidden_field(:document_fedora, :coordinates_title, :value => coordinates_title )}
      EOS
      map.html_safe
    end
  end

  
  def display_google_static_map(coordinates, dt_title)
    unless coordinates.nil?
      coordinates = coordinates.first if coordinates.kind_of? Array    
      encoded_polyline =  create_polyline(get_coordinate_list( coordinates ) )

      map = <<-EOS
        <dt>#{dt_title}</dt>
        <dd>
         <img src="#{get_static_google_map_url(encoded_polyline)}" alt="Map">
        </dd>
      EOS
      map.html_safe
    end
  end
  
  def get_static_google_map_url(encoded_polyline)
      map_size = "500x281"
      fillcolor = "0xAA000033"
      color = "0xFFFFFF00"
      
      google_maps_url = "https://maps.googleapis.com/maps/api/staticmap?sensor=false&size=" + map_size + "&path=fillcolor:" + fillcolor + "%7Ccolor:" + color + "%7Cenc:" + encoded_polyline[:points] + ""  
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
