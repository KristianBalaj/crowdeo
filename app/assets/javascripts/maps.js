function addMap(tag_id, lat_lng_view_arr, zoom = 15)
{
    var mymap = L.map(tag_id).setView(lat_lng_view_arr, zoom);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(mymap);

    return mymap;
}

/**
 * Returns an array of two elements [latitude, longitude].
 * On location decided, onSuccess callback is called with 2 parameters (latitude, longitude).
 */
function getLocation(onSuccess, onFail)
{
    var request = new XMLHttpRequest();

    request.onload = function()
    {
        if(request.status >= 200 && request.status < 300)
        {
            var location = JSON.parse(request.response);
            onSuccess(location.lat, location.lon);
        }
        else
        {
            onFail();
        }
    };

    request.open('GET', 'http://ip-api.com/json');
    request.send();
}