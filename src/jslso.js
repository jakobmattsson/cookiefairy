// Dont forget to include the following files before this one:
// * http://ajax.googleapis.com/ajax/libs/jquery/1.3.1/jquery.min.js
// * http://ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js

$(document).ready(function(){
  var url = "../bin/jslso.swf";

  var outer = document.createElement('div');
  outer.style.position = "relative";
  outer.style.left = "-10000px";
  document.getElementsByTagName("body")[0].appendChild(outer);
  
  var id = "SharedObjects-swf";
  var inner = document.createElement('div');
  inner.id = id;
  outer.appendChild(inner);
  
  swfobject.embedSWF(url, inner.id, 1, 1, "7", null, { embedId: id, debug: "console.log" }, { allowScriptAccess: "always" }, { id: id, name: id });
});
