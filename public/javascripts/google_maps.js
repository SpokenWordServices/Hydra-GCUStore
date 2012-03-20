$(document).ready(function(){
  initialize();
})

function initialize() {
  displayMap(); 
}


function displayMap() {
 coords = getCoordinates();
 coords_count = coords.length

 if (coords_count == 1) {
  singlePlacemark(coords[0].longitude, coords[0].latitude)

 }
 else if (coords_count > 1) {
   polygonPlacemarks(coords)
 }

}


function singlePlacemark(longitude, latitude) {

  var myLatlng = new google.maps.LatLng( latitude, longitude);

  var myOptions = {
    zoom: 10,
    center: myLatlng,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
  }
  var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);

  var marker = new google.maps.Marker({
      position: myLatlng,
      title:"Dataset marker"
  });

  // To add the marker to the map, call setMap();
  marker.setMap(map);
}



function polygonPlacemarks(coords) {

 var myLatLng = new google.maps.LatLng(coords[0].latitude, coords[0].longitude);

 var myOptions = {
   zoom: 5,
   center: myLatLng,
   mapTypeId: google.maps.MapTypeId.ROADMAP
  };

 var polygon_area;
 var polygon_coords = [];
 var latlngbounds =  new google.maps.LatLngBounds();


 var map = new google.maps.Map(document.getElementById("map_canvas"),
      myOptions);

  coords_count = coords.length

  
  //Add the coords to the polygone object...
  for(var i=0; i<coords_count; i++) {   
     polygon_coords.push(new google.maps.LatLng(coords[i].latitude, coords[i].longitude));
     latlngbounds.extend(new google.maps.LatLng(coords[i].latitude, coords[i].longitude));     
  }

  map.setCenter(latlngbounds.getCenter());
  map.fitBounds(latlngbounds);

  polygon_area = new google.maps.Polygon({
    paths: polygon_coords,
    strokeColor: "#FF0000",
    strokeOpacity: 0.8,
    strokeWeight: 3,
    fillColor: "#FF0000",
    fillOpacity: 0.35
  });

  polygon_area.setMap(map);
}


function getCoordinates() {

  var coordinates = $("#document_fedora_coordinates").val();
  var coordinates_array = coordinates.split(" ");
  var count = coordinates_array.length
 
  var array_of_coord_objs = [];

  for(var i=0; i<count; i++) {
    
    var coords = coordinates_array[i].split(",")

    if (coords.length == 2) 
    {
      //var coord = new coordinate(coords[0], coords[1], "");
      array_of_coord_objs.push( new coordinate(coords[0], coords[1], "") );
    }
    else if (coords.length == 3)
    {
       array_of_coord_objs.push( new coordinate(coords[0], coords[1], coords[2]) );
    }
  }
  return array_of_coord_objs;
}


 function coordinate(longitude, latitude, altitude)
 {
  this.longitude=longitude;
  this.latitude=latitude;
  this.altitude;
 }









