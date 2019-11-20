import React, { useState, useEffect } from 'react';
import './App.css';

import Button from '@material-ui/core/Button';
import Dialog from '@material-ui/core/Dialog';
import DialogActions from '@material-ui/core/DialogActions';
import DialogContent from '@material-ui/core/DialogContent';
import DialogContentText from '@material-ui/core/DialogContentText';
import DialogTitle from '@material-ui/core/DialogTitle';

let isUIReady = false;
const DBG = true;

function App() {

  const [open, setOpen] = React.useState(false);
  const [title, setTitle] = React.useState("");
  const [contentText, setContentText] = React.useState("");

  // Similar to componentDidMount and componentDidUpdate:
  useEffect(() => {
    // Update the document title using the browser API
    if (!isUIReady) {
      isUIReady = true;
      if (DBG) console.log("Try to request user's location at first");
      getLocation();
    }
  });

  const onButtonGetLocationPressed = () => {
    if (DBG) console.log(">> onButtonGetLocationPressed");
    setOpen(false);
    getLocation();
  }

  const getLocation = () => {
    setTimeout(() => {
      if (navigator.geolocation) {
        if (DBG) console.log(">> Ready to get geolocation", new Date());
        navigator.geolocation.getCurrentPosition(showPosition, showError);
      } else {
        console.warn("Geolocation is not supported by this browser.");
      }
    }, 200);
  }

  const showPosition = (position) => {
    if (DBG) console.log(">> showPosition", position);
    setTitle("Your Geolocation");
    setContentText(
      "Latitude: " + position.coords.latitude + ", "
      + "Longitude: " + position.coords.longitude);
    if (DBG) console.log(">> setOpen");
    setOpen(true);

    let geoInfo = {
      command: "message_from_binghuan_webapp_requestlocation",
      lat: position.coords.latitude,
      lng: position.coords.longitude
    };
    window.postMessage(geoInfo, "*");
  }

  const showError = (error) => {
    if (DBG) console.log(">> showError", error);
    let messageText = "";
    let title = "";
    switch (error.code) {
      case error.PERMISSION_DENIED:
        title = "error.PERMISSION_DENIED";
        messageText = "User denied the request for Geolocation.";
        break;
      case error.POSITION_UNAVAILABLE:
        title = "error.POSITION_UNAVAILABLE";
        messageText = "Location information is unavailable.";
        break;
      case error.TIMEOUT:
        title = "error.TIMEOUT";
        messageText = "The request to get user location timed out.";
        break;
      case error.UNKNOWN_ERROR:
        title = "error.UNKNOWN_ERROR";
        messageText = "An unknown error occurred.";
        break;
    }
    if (DBG) console.log("<< showError", title, messageText);

    setTitle(title);
    setContentText(messageText);
    setOpen(true);
  }

  // const handleClickOpen = () => {
  //   console.log(">> setOpen");
  //   setOpen(true);
  // };

  // const handleClose = () => {
  //   console.log(">> handleClose");
  //   setOpen(false);
  // };

  return (
    <div className="App">
      <header className="App-header"
        style={{ backgroundImage: "url( './background.jpg')" }}>
        <p style={{
          fontSize: "1rem",
          position: "absolute",
          bottom: 0,
          left: 0,
          paddingLeft: "10px",
          paddingBottom: "10px"
        }}>
          Image by Daniel R. Strebe</p>
      </header>
      <Dialog
        open={open}
        aria-labelledby="alert-dialog-title"
        aria-describedby="alert-dialog-description"
      >
        <DialogTitle id="alert-dialog-title">{title}</DialogTitle>
        <DialogContent>
          <DialogContentText id="alert-dialog-description">
            {contentText}
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button onClick={onButtonGetLocationPressed}
            color="primary" autoFocus>
            Get Location
        </Button>
        </DialogActions>
      </Dialog>
    </div>
  );
}

export default App;
