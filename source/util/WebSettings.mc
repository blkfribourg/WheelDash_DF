import Toybox.Communications;
import Toybox.System;
import Toybox.Lang;
using Toybox.Application.Properties;
using Toybox.WatchUi;
using Toybox.Application.Storage;

class WebSettings {
  var confirm = false;
  var fetchCnt = 0;

  var jsonSettings;
  var uid;
  var url;
  var callable = new Lang.Method($, :onReceive);

  function setParams(_uid, _url) {
    uid = _uid;
    url = _url;
  }
  (:background)
  function fetch() {
    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_POST, // set HTTP method
      :headers => {
        // set headers
        "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED,
        //"Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
      },
      // set response type
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
    };
    if (Communications has :makeWebRequest) {
      //  System.println(url);

      Communications.makeWebRequest(
        url,
        { "uid" => uid },
        options,
        method(:onReceive)
      );
      fetchCnt++;
    }
  }
  function setSettings(json as Dictionary) {
    if (json != null) {
      Storage.setValue("JSONSettings", json);
      setProfilesNb(json.get("settings") as Dictionary);
    }

    eucData.settingsChanged = true;
  }
  (:background)
  public function onReceive(
    responseCode as Number,
    data as Dictionary or String or Null
  ) as Void {
    System.println(responseCode);
    //System.println(data);
    if (responseCode == 200 && data != null) {
      setSettings(data);
      //}

      eucData.JSONFetch = "fetched";
    } else {
      if (fetchCnt < 3) {
        //wait
      } else {
        var localJSON = Storage.getValue("JSONSettings");
        if (localJSON != null) {
          //  if (eucData.profilesNb > 3) {
          setSettings(localJSON);
          //}

          eucData.JSONFetch = "fetched";
        } else {
          // eucData.JSONFetch = "none";
        }
      }
    }
  }

  function compareJSON(json1 as Dictionary, json2 as Dictionary) {
    // If both are not dictionaries, compare directly
    if (!(json1 instanceof Dictionary) || !(json2 instanceof Dictionary)) {
      return json1.equals(json2);
    }

    // Get keys and compare their sizes
    var keys1 = json1.keys() as Array;
    var keys2 = json2.keys() as Array;
    if (keys1.size() != keys2.size()) {
      return false;
    }

    for (var i = 0; i < keys1.size(); i++) {
      var key = keys1[i];
      if (!json2.hasKey(key)) {
        return false;
      }

      var value1 = json1.get(key);
      var value2 = json2.get(key);

      // If both values are dictionaries, recurse
      if (value1 instanceof Dictionary && value2 instanceof Dictionary) {
        if (!compareJSON(value1, value2)) {
          return false;
        }
      } else if (!value1.equals(value2)) {
        return false;
      }
    }

    return true;
  }

  function setProfilesNb(json) {
    var keys = json.keys() as Array;
    for (var i = 0; i < keys.size(); i++) {
      //System.println(keys[i]);
      var currentKey = json.get(keys[i]) as Dictionary;

      //checking if additionnal profiles:
      var pStrIdx = keys[i].find("_p");
      if (pStrIdx != null) {
        var pStr = keys[i].substring(pStrIdx + 2, null);
        if (pStr != null) {
          if (pStr.toNumber() > eucData.profilesNb) {
            //     System.println("new profile detected:" + pStr);
            eucData.profilesNb = pStr.toNumber(); // updating last profile id
          }
        }
      }
    }
  }
}
