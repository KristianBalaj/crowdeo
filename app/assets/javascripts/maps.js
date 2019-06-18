function addMap(tag_id, lat_lng_view_arr, zoom)
{
    var mymap = L.map(tag_id).setView(lat_lng_view_arr, zoom);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(mymap);

    return mymap;
}
