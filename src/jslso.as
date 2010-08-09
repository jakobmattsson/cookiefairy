import flash.external.ExternalInterface;

var sharedObjects = { };
var keyCounter = 0;
var embedId = _root.embedId.toString();

var debugFunc = "function(msg) {"
  + "if (window && window.SharedObject && typeof window.SharedObject.debugLog == 'function')"
  + "  window.SharedObject.debugLog(msg);"
  + "}";

var embedFunc = "function(embedId) {"
  + "  var fla = document.getElementById(embedId);"
  + "  if (!window.SharedObject)"
  + "    window.SharedObject = {};"
  + "  SharedObject.getLocal = function(name, localPath, secure) {"
  + "    var id = fla.soGetLocal(name, localPath, secure);"
  + "    if (!id) return undefined;"
  + "    return {"
  + "      flush: function(minimumDiskSpace) { return fla.soFlush(id, minimumDiskSpace); },"
  + "      close: function() { return fla.soClose(id); },"
  + "      getSize: function() { return fla.soGetSize(id); },"
  + "      getData: function() { return fla.soGetData(id); },"
  + "      deleteData: function(key) { return fla.soDeleteData(id, key); },"
  + "      setData: function(key, value) { return fla.soSetData(id, key, value); }"
  + "    };"
  + "  };"
  + "  if (typeof SharedObject.onload == 'function')"
  + "    SharedObject.onload();"
  + "}";


function debugLog(str) {
  ExternalInterface.call(debugFunc + "('" + str.split("'").join("\\\'") +  "')");
}

ExternalInterface.addCallback("soGetLocal", null, function(name, localPath, secure) {
  try {
    debugLog("soGetLocal('" + name + "', '" + localPath + "', " + !!secure + ")");
    var so = SharedObject.getLocal(name, localPath, !!secure);
    so.onStatus = function(infoObject) {
      // What to do here?
      ExternalInterface.call("alert('shared object invoked onStatus')");
    };
    keyCounter += 1;
    debugLog("Assigning the key '" + keyCounter + "' to this local shared object");
    sharedObjects[keyCounter.toString()] = so;
    return keyCounter.toString();
  } catch (e) {
    debugLog("Error caught in soGetLocal: " + e.toString());
    return undefined;
  }
});

ExternalInterface.addCallback("soGetData", null, function(id) {
  try {
    debugLog("soGetData('" + id + "')");
    return sharedObjects[id].data;
  }
  catch (e) {
    debugLog("Error caught in soGetData: " + e.toString());
    return undefined;
  }
});

ExternalInterface.addCallback("soSetData", null, function(id, key, value) {
  try {
    debugLog("soSetData('" + id + "', '" + key + "', '" + value + "')");
    sharedObjects[id].data[key] = value;
    return true;
  } catch (e) {
    debugLog("Error caught in soSetData: " + e.toString());
    return false;
  }
});

ExternalInterface.addCallback("soDeleteData", null, function(id, key) {
  try {
    debugLog("soDeleteData('" + id + "', '" + key + "')");
    delete sharedObjects[id].data[key];
    return true;
  } catch (e) {
    debugLog("Error caught in soDeleteData: " + e.toString());
    return false;
  }
});

ExternalInterface.addCallback("soGetSize", null, function(id) {
  try {
    debugLog("soGetSize('" + id + "')");
    return sharedObjects[id].getSize();
  } catch (e) {
    debugLog("Error caught in soGetSize: " + e.toString());
    return undefined;
  }
});

ExternalInterface.addCallback("soFlush", null, function(id, minimumDiskSpace) {
  try {
    debugLog("soFlush('" + id + "', " + minimumDiskSpace + ")");
    return sharedObjects[id].flush(minimumDiskSpace);
  } catch (e) {
    debugLog("Error caught in soFlush: " + e.toString());
    return false; // This is not really satisfying. What to return here?
  }
});

ExternalInterface.addCallback("soClose", null, function(id) {
  try {
    debugLog("soClose('" + id + "')");
    delete sharedObjects[id];
    return true;
  } catch (e) {
    debugLog("Error caught in soClose: " + e.toString());
    return false;
  }
});

ExternalInterface.call(embedFunc + "('" + embedId + "')");
