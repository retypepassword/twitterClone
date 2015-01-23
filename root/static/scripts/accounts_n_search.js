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

$("#search_box").parent().submit(function(e) {
  window.location = '/search/' + encodeURIComponent(this.query.value);
  e.preventDefault();
});

$("#login").on("show.bs.modal", function(e) {
  var link = e.relatedTarget;
  var action = link.getAttribute("data-act");
  var num_to_unhide, to_unhide, to_hide;
  
  if ( action == "up" ) {
    to_unhide = $(this).find(".signup.hidden");
    to_hide = $(this).find(".signin");
    num_to_unhide = to_unhide.length;
    
    $("#acct-form")[0].action = '/account/create';
  }
  else {
    to_unhide = $(this).find(".signin.hidden");
    to_hide = $(this).find(".signup");
    num_to_unhide = to_unhide.length;
    
    $("#acct-form")[0].action = '/account/login';
  }
  
  if (num_to_unhide > 0) {
    for (var i = 0; i < num_to_unhide; i++) {
      to_unhide[i].className = to_unhide[i].className.replace("hidden", "");
    }
    for (var i = 0; i < to_hide.length; i++) {
      to_hide[i].className += " hidden";
    }
  }
});

var signup_in_handler = function(action) {
  return function(e) {
    if (action.length == 0) {
      action = $("#acct-form")[0].action;
    }
    $.post( action, $("#acct-form").serialize(), function(data) {
      if (data.status == "User created" || data.status == "Logged in") {
        location.reload(true);
      }
      else {
        $("#err .message").html(data.status);
        $("#err")[0].className = $("#err")[0].className.replace("hidden", "");
      }
    });
    
    e.preventDefault();
  };
};

$("#signup").click(signup_in_handler("/account/create"));
$("#signin").click(signup_in_handler("/account/login"));
$("#acct-form").submit(signup_in_handler(""));

$("#err button").click(function(e) {
  $("#err")[0].className += " hidden";
});