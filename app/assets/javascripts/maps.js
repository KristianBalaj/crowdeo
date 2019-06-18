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
 * Checks permission for exact location. When permission not allowed, returns approximate location.
 * On location decided, onSuccess callback is called with 2 parameters (latitude, longitude).
 */
function getLocation(onSuccess, onFail)
{
    var calculateApproximateLocation = function(onLocationCaptured)
    {
        var request = new XMLHttpRequest();

        request.onload = function()
        {
            if(request.status >= 200 && request.status < 300)
            {
                var location = JSON.parse(request.response);
                onLocationCaptured(location.lat, location.lon);
            }
            else
            {
                onFail();
            }
        };

        request.open('GET', 'http://ip-api.com/json');
        request.send();
    };

    if(navigator.geolocation)
    {
        var geoSuccess = function(result)
        {
            onSuccess(result.coords.latitude, result.coords.longitude);
        };

        var geoErr = function(result)
        {
            calculateApproximateLocation(function(lat, lon) {
                onSuccess(lat, lon);
            });
        };

        navigator.geolocation.getCurrentPosition(geoSuccess, geoErr);
    }
    else
    {
        calculateApproximateLocation(function(lat, lon) {
            onSuccess(lat, lon);
        });
    }
}