function loginClicked() {
  var elem = document.getElementById('login-fields');
  if (elem.style.visibility == "visible") {
    elem.style.visibility = "hidden";
  } else {
    elem.style.visibility = "visible";
  }
}

function commentClicked(id) {
  var link = document.getElementById("comment-link-" + id);
  var comments = document.getElementById("comment-area-" + id);
  
  if (link.text.substring(0,1) == String.fromCharCode('09654')) { // closed
    // open it
    comments.style.display = "inline";
    link.text = String.fromCharCode('0x25bc') + link.text.substring(1);
  } else {
    // close it
    comments.style.display = "none";
    link.text = String.fromCharCode('09654') + link.text.substring(1);
  }
}
