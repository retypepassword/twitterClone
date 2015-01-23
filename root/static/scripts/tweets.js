/* tweets.js: Handles POSTing tweets to server, preventing tweet from being too long, and retrieving/displaying new ones */

var MAX_TWEET_LENGTH = 150;

$("#post-tweet").submit(function(e) {
  $.post( "/api/tweet", { "tweet" : $("#twt")[0].value }, function(data) {
    $("#post-tweet").parent().after("<div class=\"tweet-wrapper\"><div class=\"tweet\">" +
                                    "<div class=\"text\">" + data.text + "</div>" +
                                    "<div class=\"meta\"><span class=\"author text-muted\">by <a href=\"/" + data.username + "\">@" +
                                    data.username + "</a> (" + data.author + ")</span>" +
                                    "<span class=\"time text-muted\">" + data.date + "</span><br class=\"clear\">" +
                                    "</div></div><div class=\"options\"><a href=\"#\" class=\"remove text-danger hidden\">" +
                                    "<i class=\"glyphicon glyphicon-remove\"></i></a></div><br class=\"clear\"></div>");
    $("#twt")[0].value = "";
    $("#twt").keyup();
  }, "json");
  e.preventDefault();
});

$("#twt").keyup(function(e) {
  var len = MAX_TWEET_LENGTH - parseInt(this.value.length);
  
  if (len < 0) {
    var text = this.value;
    this.value = text.substr(0, MAX_TWEET_LENGTH);
    len = 0;
  }
  
  $("#post-tweet .text-muted").html(len + " characters left");
});