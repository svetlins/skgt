$(function () {
    var spinner_on = function () { $('#spinner').fadeTo(50, 1); }
    var spinner_off = function () { $('#spinner').fadeTo(300, 0); }

    var ttype = $('select[name="ttype"]');
    var line = $('select[name="line"]');
    var route = $('select[name="route"]');
    var stop = $('select[name="stop"]');

    var time = $('div#time');


    // bind behaviour to fields - every field populates and discards the next
    ttype.change(function () {
        spinner_on();
        $.get(
            '/lines/',
            {'ttype' : ttype.val()},
            function (data) {
                line.find('option:not(.empty)').remove();
                route.find('option:not(.empty)').remove();
                stop.find('option:not(.empty)').remove();
                time.children().remove();

                for(var i=0;i<data.length;i++) {
                    var element = data[i];

                    if (!element) { continue; } // buggy API gives null in the beginning sometimes

                    var
                        name = element[0],
                        id = element[1];

                    var option = $('<option>');
                    option.text(name);
                    option.attr('value', id);

                    line.append(
                        option
                    );

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
                route.find('option:not(.empty)').remove();
                stop.find('option:not(.empty)').remove();
                time.children().remove();

                for(var i=0;i<data.length;i++) {
                    var element = data[i];

                    if (!element) { continue; } // buggy API gives null in the beginning sometimes

                    var 
                        name = element[0],
                        id = element[1];

                    var option = $('<option>');
                    option.text(name);
                    option.attr('value', id);

                    route.append(
                        option
                    );
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
                stop.find('option:not(.empty)').remove();
                time.children().remove();

                for(var i=0;i<data.length;i++) {
                    var element = data[i];

                    if (!element) { continue; } // buggy API gives null in the beginning sometimes

                    var 
                        name = element[0],
                        id = element[1];

                    var option = $('<option>');
                    option.text(name);
                    option.attr('value', id);

                    stop.append(
                        option
                    );
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
            function (data) {
                time.children().remove();

                for(var i=0;i<data.length;i++) {
                    var element = data[i];

                    if (!element) { continue; } // buggy API gives null in the beginning sometimes

                    var div = $('<div>');
                    div.text(element);

                    time.append(
                        div
                    );
                }
                spinner_off();
            },
            'json'
        );
    });

});
