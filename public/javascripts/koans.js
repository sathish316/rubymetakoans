$(function () {
  var firstFail = $(".failed:first"),
      offset    = firstFail.offset(),
      top       = offset ? offset.top : 0;

  firstFail.find("input:first").focus();
  $("html,body").animate({scrollTop: top - 280}, 0);

  if($('#rotateTeam').length > 0){
    $('#rotateTeam').cycle({ fx: 'shuffle' });
  }
});
