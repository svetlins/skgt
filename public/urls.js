$(function () {

    var ttype = $('select[name="ttype"]');
    var line = $('input[name="line"]');
    var route = $('select[name="route"]');
    var stop = $('select[name="stop"]');
    var line_ac = $('input[name=line_ac]');

    var fields = [
        ttype,
        line,
        line_ac,
        route,
        stop
    ];
    
    var get_current_url = function () {
        
        var url = location.protocol + '//' + location.host + location.pathname;
        var params = [];
        var current_url = '';

        for (var i = 0; i < fields.length; i++) {
            var field = fields[i];

            if (field.val().length > 0) {
                params.push(
                    field.attr('name') + '=' + field.val()
                );
            }
        }
        
        if (params.length > 0) {
            current_url = url + '?' + params.join('&');
        } else {
            current_url = url;
        }

        return current_url;
    };

    test = get_current_url;

    var get_url_params = function () {
        var href = location.href;
        var params = {};

        href.slice(href.indexOf('?') + 1).split('&').forEach(function (datum) {
            var kv = datum.split('=');
            params[kv[0]] = kv[1];
        });
        
        return params;
    };

    var set_state = function () {
        var params = get_url_params();

        for (var i = 0; i < fields.length; i++) {
            var field = fields[i];
            
            if (params[field.attr('name')]) {
                field.val(params[field.attr('name')]);
                field.change();
            }
        }
    }; 

    test2 = set_state;
});
