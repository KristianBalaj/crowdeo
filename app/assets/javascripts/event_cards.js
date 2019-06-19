function getEventCardNode(
    show_event_href,
    edit_event_href,
    event_name,
    attendance_count,
    organizer_nick,
    event_description,
    created_time_ago,
    is_user_organizer)
{
    return $('<div>', {'class': 'col-md-4'}).append(
        $('<div>', {'class': 'card mb-4 shadow-sm'}).append(
            $('<div>', {'class': 'card-body'}).append(
                $('<h5>', {'class': 'card-title'}).text(event_name),
                $('<h6>', {'class': 'card-subtitle mb-2 text-muted'}).text('Organizer: ' + organizer_nick),
                $('<h6>', {'class': 'card-subtitle mb-2 text-muted'}).text('Total attendance: ' + attendance_count),
                $('<p>', {'class': 'card-text'}).text(event_description),
                $('<div>', {'class': 'd-flex justify-content-between align-items-center'}).append(
                    $('<div>', {'class': 'btn-group'}).append(
                        $('<a>', {'class': 'btn btn-sm btn-outline-secondary', 'href': show_event_href}).text('View'),
                        $('<a>', {'display': (is_user_organizer ? 'block' : 'none'), 'class': 'btn btn-sm btn-outline-secondary', 'href': edit_event_href}).text('Edit')
                    )
                )
            ),
            $('<div>', {'class': 'card-footer text-muted'}).append(
                $('<small>', {'class': 'text-muted'}).text(created_time_ago)
            )
        ));
}