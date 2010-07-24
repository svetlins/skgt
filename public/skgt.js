$(function () {

    var ttype = $('select[name="ttype"]');
    var line = $('select[name="line"]');
    var route = $('select[name="route"]');
    var stop = $('select[name="stop"]');

    var time = $('div#time');

    ttype.change(function () {
        $.get(
            '/lines/',
            {'ttype' : ttype.val()},
            function (data) {
                line.find('option:not(.empty)').remove();
                route.find('option:not(.empty)').remove();
                stop.find('option:not(.empty)').remove();
                time.children().remove();

                for(key in data) {

                    var option = $('<option>');
                    option.text(key);
                    option.attr('value', data[key]);

                    line.append(
                        option
                    );
                }
            },
            'json'
        );
    });

    line.change(function () {
        $.get(
            '/routes/',
            {'ttype' : ttype.val(), 'line' : line.val()},
            function (data) {
                route.find('option:not(.empty)').remove();
                stop.find('option:not(.empty)').remove();
                time.children().remove();

                for(var i=0;i<data.length;i++) {
                    var element = data[i];
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
            },
            'json'
        );
    });

    route.change(function () {
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
            },
            'json'
        );
    });

    stop.change(function () {
        $.get(
            '/times/',
            {'ttype' : ttype.val(), 'line' : line.val(), 'route' : route.val(), 'stop' : stop.val()},
            function (data) {
                time.children().remove();

                for(var i=0;i<data.length;i++) {
                    var element = data[i];

                    if (!element) { continue; } // buggy API gives null in the beginning sometimes

                    var span = $('<span>');
                    span.text(element);

                    time.append(
                        span
                    );
                }
            },
            'json'
        );
    });

});
