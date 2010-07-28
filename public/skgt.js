$(function () {
    var spinner_on = function () {
        $('#spinner').show();
    }

    var spinner_off = function () {
        $('#spinner').hide();
    }

    var ttype = $('select[name="ttype"]');
    var line = $('select[name="line"]');
    var route = $('select[name="route"]');
    var stop = $('select[name="stop"]');

    var time = $('#times');

    var render_times = function (times) {
        var container = $('<div />');

        if (times.length > 0) {
            
            var main_time = $('<div />');
            main_time.attr('id', 'main-time');
            main_time.text(times[0]);

            var other_times = $('<div />');
            other_times.attr('id', 'other-times');

            if (times.slice(1).length > 0) {
                other_times.text(times.slice(1).join(', '));
            } else {
                other_times.text('Няма');
            }

            container.append(main_time);
            container.append(other_times);

        } else {
            var sorry = $('<div />');
            sorry.attr('id', 'sorry');

            container.append(sorry);
        }

        return container;
    }

    $.fn.extend({
        'create_option' : function (key, value) {
            if ($(this).is('select')) {
                var option = $('<option>');

                option.attr('value', key);
                option.text(value);
                $(this).append(option);
                $(this).attr('disabled', false);
            }
        },
        'deactivate' : function () {
            if ($(this).is('select')) {
                $(this).find('option:not(.empty)').remove();
                $(this).attr('disabled', true);
            }
        }
    });



    // bind behaviour to fields - every field populates and discards the next
    var set_fields_behav = function (cache) {

    ttype.change(function () {
        line.deactivate();
        route.deactivate();
        stop.deactivate();

        time.children().remove();
        
        var lines = cache[ttype.val()]['lines'];

        for(line_id in lines) {
            var
                name = lines[line_id]['name'],
                id = line_id;


            line.create_option(id, name);

        }

    });

    line.change(function () {
        route.deactivate();
        stop.deactivate();

        time.children().remove();

        var routes = cache[ttype.val()]['lines'][line.val()]['routes'];

        for(route_id in routes) {

            var 
                name = routes[route_id]['name'],
                id = route_id;

            route.create_option(id, name);

        }
    });

    route.change(function () {
        stop.deactivate();

        time.children().remove();

        var stops = cache[ttype.val()]['lines'][line.val()]['routes'][route.val()]['stops'];

        for(var i=0; i<stops.length; i++) {
            var a_stop = stops[i];

            var 
                name = a_stop[0],
                id = a_stop[1];

            stop.create_option(id, name);
        }
    });

    stop.change(function () {
        spinner_on();
        $.get(
            '/times/',
            {'ttype' : ttype.val(), 'line' : line.val(), 'route' : route.val(), 'stop' : stop.val()},
            function (times) {
                time.children().remove();

                time.append(render_times(times));

                spinner_off();
            },
            'json'
        );
    });

    }

    $.get(
        '/cache/',
        {},
        function (cache) {
            c = cache;
            set_fields_behav(cache);
        },
        'json'
    );

});
