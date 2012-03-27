$(document).ready(function(){
  initialize();
})

function initialize() {

  displayMap(); 
}


function displayMap() {

  var object_id = getUrlVars()["object_id"];
  var ds_id  = getUrlVars()["ds_id"];
  var map_file_url = window.location.protocol + "//" + window.location.host + "/assets/" + object_id + "/" + ds_id;

  var myLatlng = new google.maps.LatLng(53.771152,0.368149);
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



