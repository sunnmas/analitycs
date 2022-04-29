function DowncountTimer() {
    var time_left = undefined;
    var timer_el = undefined;
    var timer = undefined;
    var action = undefined;
    var frmt = new Intl.NumberFormat('en-US', {
        minimumIntegerDigits: 2,
        minimumFractionDigits: 0
    });
    var timer_type = 'downcounter';

    var run = function(){
        timer = setInterval(function() {
            render();
            if (time_left <= 0) {
                clearInterval(timer);
                if (action != undefined) action();
            }
            if (timer_type == 'downcounter') {
                time_left = time_left - 1;
            } else {
                time_left = time_left + 1;
            }
        }, 1000);
    }
    var render = function(){
        var h = Math.floor(time_left / 3600);
        var m = Math.floor((time_left - 3600*h) / 60);
        var s = (time_left - 3600*h - 60*m);
        timer_el.text(frmt.format(h)+':'+frmt.format(m)+':'+frmt.format(s));
    }
    var init = function(t_el, t, act, type){
        timer_el = $(t_el);
        time_left = t;
        action = act;
        if (type != undefined) { timer_type = type; }
        if (timer != undefined) clearInterval(timer);
        render();
        run();
    }

    return {
        init: function(timer_el, action, type){
            if (action==undefined) {action = function(){}}
            time_left = $(timer_el).data('time');
            init(timer_el, time_left, action, type);
        }
    }
}
