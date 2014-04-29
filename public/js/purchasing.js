$( document ).ready(function() {
  $('a.print').click(function(event) {
    var _window = window.open($(this).attr('href'));
    _window.focus();
    _window.print();
    event.preventDefault();
  });
});
