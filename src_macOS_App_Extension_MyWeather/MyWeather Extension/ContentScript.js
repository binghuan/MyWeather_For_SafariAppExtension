console.log("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@1");
document.addEventListener("DOMContentLoaded", function (event) {
  console.log("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@2");
  safari.extension.dispatchMessage("Hello World!");

});


window.addEventListener("message", receiveMessage, false);

function receiveMessage(event) {
  console.log(">> receiveMessage: ", event);

  // Do we trust the sender of this message?  (might be
  // different from what we originally opened, for example).
  if ((event.origin.indexOf("127.0.0.1") !== -1) &&
    (event.origin.indexOf("localhost") !== -1) &&
    (event.origin.indexOf("ngok.io") !== -1)) {

    console.warn("NG> Not Supported Website: ", event.origin);

    return;
  } {
    console.log("OK> It is good to go!");
  }


  if (event.data.hasOwnProperty("lat") &&
    event.data.hasOwnProperty("lng")) {

    console.log("Ready to send meesage to app extension!");

    safari.extension.dispatchMessage(event.data.lat + "," + event.data.lng);
  }
}

