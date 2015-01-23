$("#follow").click(function(e){
  e.preventDefault();
  
  var icon = "minus";
  var act = "follow";
  var text = "Un-Follow";
  var id = this.getAttribute("data-uid");
  
  if (this.innerHTML.contains("Un-Follow")) {
    icon = "plus";
    act = "unfollow"
    text = "Follow"
  }
  
  var self = this;
  $.post( "api/follow", { uid : id, action : act }, function(data) {
    if (data.success == 1)
      self.innerHTML = "<i class=\"glyphicon glyphicon-" + icon + "\"></i> " + text;
  }, "json");
});

$("#search_box")