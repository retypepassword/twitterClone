/* tweets.js: Handles POSTing tweets to server, preventing tweet from being too long, and retrieving/displaying new ones */

var MAX_TWEET_LENGTH = 150;

/* posts a tweet and adds it beneath the tweeting box */
$("#post-tweet").submit(function(e) {
  $.post( "/api/tweet", { "tweet" : $("#twt")[0].value }, function(data) {
    $("#post-tweet").parent().after("<div class=\"tweet-wrapper\"><div class=\"tweet\">" +
                                    "<div class=\"text\">" + data.text + "</div>" +
                                    "<div class=\"meta\"><span class=\"author text-muted\">by <a href=\"/" + data.username + "\">@" +
                                    data.username + "</a> (" + data.author + ")</span>" +
                                    "<span class=\"time text-muted\">" + data.date + "</span><br class=\"clear\">" +
                                    "</div></div><div class=\"options\"><a href=\"#\" class=\"remove text-danger hidden\" data-id=\"" + data.id + "\">" +
                                    "<i class=\"glyphicon glyphicon-remove\"></i></a></div><br class=\"clear\"></div>");
    $("#twt")[0].value = "";
    $("#twt").keyup();
    
    /* Activates the x buttons so the user can delete the tweet that was just posted if they want */
    activate_delete_buttons();
  }, "json");
  e.preventDefault();
});

/* Prevents tweets from being more than MAX_TWEET_LENGTH characters */
$("#twt").keyup(function(e) {
  var len = MAX_TWEET_LENGTH - parseInt(this.value.length);
  
  if (len < 0) {
    var text = this.value;
    this.value = text.substr(0, MAX_TWEET_LENGTH);
    len = 0;
  }
  
  $("#post-tweet .text-muted").html(len + " characters left");
});

/* Shows and hides the elements with the delete buttons if the user hovers
 * over the tweet. Adds click handler for deleting via XHR */
function activate_delete_buttons() {
  $(".tweet-wrapper").mouseover(function(e) {
    if ($(this).find('.options a')[0]) {
      $(this).find('.options a')[0].className = "text-danger";
    }
  });

  $(".tweet-wrapper").mouseout(function(e) {
    if ($(this).find('.options a')[0]) {
      $(this).find('.options a')[0].className = "text-danger hidden";
    }
  });
  
  $('.tweet-wrapper .options a').click(function(e) {
    e.preventDefault();

    var self = this;  
    $.post( "/api/delete_tweet", { "tweet" : $(this).attr('data-id') }, function(data) {
      if (data.success == 1) {
        $(self).parentsUntil('.content').remove();
      }
    }, "json");
  });
}

activate_delete_buttons();