$( document ).ready(function() {
  $('a.print').click(function(event) {
    var _window = window.open($(this).attr('href'));
    _window.focus();
    _window.print();
    event.preventDefault();
  });
});
// click function for collapsing tables
$(document).ready(function() {
  $("div.panel-heading").click(function() {
    $(this).next(".slide").slideToggle(400);
  });
});
