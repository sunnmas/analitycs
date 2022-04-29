$(document).ready(function() {
    function closeSlider(){
        $(this).removeClass('active');
        $(this).find('img').appendTo($(this)).removeClass('zoomed');
    }
    $('.slider img').click(function(e){
        if ($(this).hasClass('zoomed')) closeSlider();
        $('.slider.active').removeClass('active');
        $('.slider img.zoomed').removeClass('zoomed');
        slider = $(this).closest('.slider');
        slider.addClass('active');
        $(this).addClass('zoomed');
        slider.find('img').not('img.zoomed').appendTo(slider.find('.previewer'));
        $(this).appendTo(slider);
        e.stopPropagation();
    });
    $('.slider').click(closeSlider)
});
