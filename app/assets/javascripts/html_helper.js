function getEventCardNode(
    show_event_href,
    edit_event_href,
    is_attending,
    is_free,
    is_night,
    event_name,
    attendance_count,
    author_nick,
    event_description,
    time_to_event_text,
    is_user_organizer,
    capacity,
    tags,
    is_popular)
{
    var attendancePerc = capacity == null ? null : Math.floor((attendance_count / capacity) * 100);
    var header = $('<div>', {'class': 'card-header text-center font-weight-bold'});
    var card_border_class = '';
    if(is_attending)
    {
        card_border_class = 'border-primary';
        header = header.text('Attending')
    }
    else if(is_popular)
    {
        card_border_class = 'border-secondary';
        header = header.text('Popular');
    }
    else
    {
        header = null;
    }

    return $('<div>', {'class': 'col-md-4'}).append(
        $('<div>', {'class': 'card mb-4 ' + card_border_class + ' shadow-sm'}).append(
            header,
            $('<div>', {'class': 'card-body', 'style': "padding-top: .75rem"}).append(
                $('<div>').append(
                    is_free ? $('<span>', {'class': 'badge badge-primary'}).text('Free') : $('<span>', {'class': 'badge badge-warning'}).text('Paid'),
                    $('<span>').text(' '),
                    is_night ? $('<span>', {'class': 'badge badge-dark'}).text('Night event') : null
                ),
                $('<h5>', {'class': 'card-title', 'style': 'font-weight: 600 !important'}).text(event_name),
                $('<h6>', {'class': 'card-subtitle mb-2'}).text(time_to_event_text),
                $('<h6>', {'class': 'card-subtitle mb-2 text-muted'}).text('Organizer: ' + author_nick),
                $('<h6>', {'class': 'card-subtitle mb-2 text-muted'}).text('Total attendance: ' + attendance_count),
                capacity == null ? null : $('<h6>', {'class': 'mb-2 text-muted'}).text('Capacity filled by:'),
                capacity == null ? null : $('<div>', {'class': 'progress'}).append(
                    $('<div>', {
                        'class': 'progress-bar progress-bar-striped',
                        'role': 'progressbar',
                        'style': 'width: ' + attendancePerc + '%',
                        'aria-valuenow': attendancePerc,
                        'aria-valuemin': 0,
                        'aria-valuemax': 100})
                ),
                $('<p>', {'class': 'card-text'}).text(event_description),
                $('<div>', {'class': 'd-flex justify-content-between align-items-center'}).append(
                    $('<div>', {'class': 'btn-group'}).append(
                        $('<a>', {'class': 'btn btn-sm btn-outline-primary', 'href': show_event_href}).text('View'),
                        $('<a>', {'display': (is_user_organizer ? 'block' : 'none'), 'class': 'btn btn-sm btn-outline-primary', 'href': edit_event_href}).text('Edit')
                    )
                )
            ),
            tags === '' ? null : $('<div>', {'class': 'card-footer text-muted'}).append(
                $('<small>').text(tags)
            )
        ));
}

function getSpinnerNode(id)
{
    return $('<span>', {'id': id, 'class': 'spinner-border spinner-border-sm', 'role': 'status', 'aria-hidden': 'true'});
}