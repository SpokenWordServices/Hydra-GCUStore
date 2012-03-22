$(document).ready(function(){
  initialize();
})

function initialize() {

  displayMap(); 
}


function displayMap() {

  var map_file_url  = getUrlVars()["map_file_url"];
  alert(map_file_url);

  var myLatlng = new google.maps.LatLng(49.496675,-102.65625);
  var myOptions = {
    zoom: 1,
    center: myLatlng,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  }

  var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);

  var georssLayer = new google.maps.KmlLayer(map_file_url);
  georssLayer.setMap(map);

}


function getUrlVars()
{
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++)
    {
        hash = hashes[i].split('=');
        vars.push(hash[0]);
        vars[hash[0]] = hash[1];
    }
    return vars;
}



