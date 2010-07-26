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
    ttype.change(function () {
        spinner_on();
        $.get(
            '/lines/',
            {'ttype' : ttype.val()},
            function (data) {
                line.deactivate();
                route.deactivate();
                stop.deactivate();

                time.children().remove();

                for(var i=0;i<data.length;i++) {
                    var element = data[i];

                    if (!element) { continue; } // buggy API gives null in the beginning sometimes

                    var
                        name = element[0],
                        id = element[1];


                    line.create_option(id, name);

                }

                spinner_off();
            },
            'json'
        );
    });

    line.change(function () {
        spinner_on();
        $.get(
            '/routes/',
            {'ttype' : ttype.val(), 'line' : line.val()},
            function (data) {
                route.deactivate();
                stop.deactivate();
                time.children().remove();

                for(var i=0;i<data.length;i++) {
                    var element = data[i];

                    if (!element) { continue; } // buggy API gives null in the beginning sometimes

                    var 
                        name = element[0],
                        id = element[1];

                    route.create_option(id, name);

                }
                spinner_off();
            },
            'json'
        );
    });

    route.change(function () {
        spinner_on();
        $.get(
            '/stops/',
            {'ttype' : ttype.val(), 'line' : line.val(), 'route' : route.val()},
            function (data) {
                stop.deactivate();
                time.children().remove();

                for(var i=0;i<data.length;i++) {
                    var element = data[i];

                    if (!element) { continue; } // buggy API gives null in the beginning sometimes

                    var 
                        name = element[0],
                        id = element[1];

                    stop.create_option(id, name);
                }
                spinner_off();
            },
            'json'
        );
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

});
