$(document).ready(function(){
    function Flash() {
        var init = function(){
            setTimeout(function() {
                $('.flashes').fadeIn(1000);
            }, 200);
            setTimeout(function() {
                $('.flashes').fadeOut(1000, function() {
                    $('.flashes').empty();
                });
            }, 20000);
        }

        return {
            init: function() {
                init();
            },
            alert: function(text){
                $('.flashes').empty();
                $('.flashes').append('<div class="flash flash_alert">'+text+'</div>');
                init();
            }
        }
    }
  window.flash = new Flash()
  window.flash.init();
});
