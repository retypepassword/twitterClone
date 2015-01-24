/* Attach a click handler to the + Follow or - Un-Follow button on a person's user page. *
 * Modifies the button appropriately (e.g., if the user clicks + Follow, the button      *
 * will say - Un-Follow after the request has been submitted (via XHR).                  */
$("#follow").click(function(e){
  e.preventDefault();
  
  var icon = "minus"; /* The button's icon after the action has been completed */
  var act = "follow"; /* Action variable to be sent to /api/follow. Specifies whether to
                         follow or unfollow.                                             */
  var text = "Un-Follow"; /* what the button will say after the action has been completed */
  var id = this.getAttribute("data-uid");
  
  if (this.innerHTML.contains("Un-Follow")) {
    icon = "plus";
    act = "unfollow"
    text = "Follow"
  }
  
  /* this changes scope in XHR (I think), so store it as self so the XHR success function can
   * modify it. */
  var self = this;
  $.post( "/api/follow", { uid : id, action : act }, function(data) {
    if (data.success == 1)
      /* Change the button */
      self.innerHTML = "<i class=\"glyphicon glyphicon-" + icon + "\"></i> " + text;
  }, "json");
});

/* Redirects a POST-based search to a chained URL-based search for better
 * usability (allows people to use the displayed URL as a link) */
$("#search_box").parent().submit(function(e) {
  window.location = '/search/' + encodeURIComponent(this.query.value);
  e.preventDefault();
});

/* Modifies the sign up or sign in modal dialog so it displays the appropriate
 * fields. The fields that need to be changed between the two "forms" have class
 * names of either sign up or signin. The two are similar enough that they share
 * the majority of their elements, so these modifications aren't that cumbersome. */
$("#login").on("show.bs.modal", function(e) {
  var link = e.relatedTarget;
  var action = link.getAttribute("data-act"); /* From the invoking link. Says whether the sign in or the sign up link was pressed. */
  var num_to_unhide, to_unhide, to_hide;
  
  /* Finds the signup elements that are currently hidden and the signin elements that should be hidden */
  if ( action == "up" ) {
    to_unhide = $(this).find(".signup.hidden");
    to_hide = $(this).find(".signin");
    num_to_unhide = to_unhide.length;
    
    /* Changes the form's action appropriately, so that the correct action is taken if the user
     * presses enter/CR in one of the fields to log in or sign up. */
    $("#acct-form")[0].action = '/account/create';
  }
  /* Analagous to the sign "up" action, except for sign in. It's the only other action, so no else if. */
  else {
    to_unhide = $(this).find(".signin.hidden");
    to_hide = $(this).find(".signup");
    num_to_unhide = to_unhide.length;
    
    $("#acct-form")[0].action = '/account/login';
  }
  
  /* Hides the other form's headers, buttons, inputs, etc. and unhides the requested form's elements. */
  if (num_to_unhide > 0) {
    for (var i = 0; i < num_to_unhide; i++) {
      to_unhide[i].className = to_unhide[i].className.replace("hidden", "");
    }
    for (var i = 0; i < to_hide.length; i++) {
      to_hide[i].className += " hidden";
    }
  }
});

/* Generic handler function that calls the appropriate login/signup and redirects
 * the user to their user page on success (see Controllers/Account.pm). Displays
 * the appropriate error message otherwise. */
var signup_in_handler = function(action) {
  /* Returns the function to call, enclosed with the appropriate action */
  return function(e) {
    /* Uses the form's action if no action was specified before the closure was made. */
    if (action.length == 0) {
      action = $("#acct-form")[0].action;
    }
    $.post( action, $("#acct-form").serialize() ).done( function(data) {
      if (data.status == "User created" || data.status == "Logged in") {
        window.location = "/" + data.user;
      }
      else {
        $("#err .message").html(data.status);
        $("#err")[0].className = $("#err")[0].className.replace("hidden", "");
      }
    });
    
    e.preventDefault();
  };
};

/* Creates appropriate click handlers for signup and signin, based on the generic
 * signup_in_handler(). */
$("#signup").click(signup_in_handler("/account/create"));
$("#signin").click(signup_in_handler("/account/login"));

/* Creates appropriate click handlers for signup and signin, based on the generic
 * signup_in_handler(). Submits requests to the action specified in the form
 * when enter is pressed. (cf. action for show.bs.modal above) */
$("#acct-form").submit(signup_in_handler(""));

/* Hides error alert boxes without removing them from the DOM. Convenient for making the
 * JS a little less messy. */
$("#err button").click(function(e) {
  $("#err")[0].className += " hidden";
});

/* Submits the appropriate action for making an account private or unprivate when the
 * checkbox displayed in the Account Settings modal dialog is checked or unchecked.
 * Makes the account private if the checkbox is checked and vice versa. Displays a
 * success alert box on success. */
$("#priv").click(function(e) {
  var private = this.checked ? "private" : "unprivate";
  var mbody = this.parentNode;
  $.post( "/account/private", { action : private }, function(data) {
    if (data.success == 1)
      $(mbody).before("<div class=\"alert alert-success alert-dismissible\" role=\"alert\">" +
                      "<button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-label=\"Close\"><span aria-hidden=\"true\">&times;</span></button>" +
                      data.result + "</div>");
  }, "json");
});