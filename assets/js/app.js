// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"
import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"


var csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
var liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}});
liveSocket.connect()

// function insertMessage() {
//     console.log("function")
//     msg = $('.message-input').val();
//     if ($.trim(msg) == '') {
//       return false;
//     }
//     $('<div class="message message-personal">' + msg + '</div>').appendTo($('.mCSB_container')).addClass('new');
//     $('.message-input').val(null);
//     updateScrollbar();
// }
  
// $('.message-submit').click(function() {
//     console.log("submited")
//     // insertMessage();
// });

$('.button').click(function(){
    $('.menu .items span').toggleClass('active');
     $('.menu .button').toggleClass('active');
});

$("body").on('DOMSubtreeModified', ".messages", function() {
    $(".messages").animate({ scrollTop: $('.messages')[0].scrollHeight}, 1000);
});

$('.message-submit').on('click', function(e) {
   console.log("submited");
    // return false;
});
  
// $(window).on('keydown', function(e) {
//     if (e.which == 13) {
//         insertMessage();
//         return false;
//     }
// });