var geocoder = new google.maps.Geocoder;

var latlng = new google.maps.LatLng(38.897275,-77.036594);
var myOptions = {
  zoom: 16,
  panControl: false,
  mapTypeControlOptions: { style: google.maps.MapTypeControlStyle.DROPDOWN_MENU},
  center: latlng,
  mapTypeId: google.maps.MapTypeId.ROADMAP
};
var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions)
var marker = new google.maps.Marker({
  position: latlng, 
  map: map
});

function updateMap(address) {
  geocoder.geocode( { 'address': address}, function(results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      $('#business_latitude').val(results[0].geometry.location.lat());
      $('#business_longitude').val(results[0].geometry.location.lng());
      $('#user_business_attributes_latitude').val(results[0].geometry.location.lat());
      $('#user_business_attributes_longitude').val(results[0].geometry.location.lng());
      map.setCenter(results[0].geometry.location);
      marker.setPosition(results[0].geometry.location);
    } else {
      alert("Geocode was not successful for the following reason: " + status);
    }
  });
}