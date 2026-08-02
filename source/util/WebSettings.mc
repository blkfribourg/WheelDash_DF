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
 // var callable = new Lang.Method($, :onReceive);

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
    if (eucData.debug) {
      System.println(responseCode);
    }
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

  function setProfilesNb(json) {
    var keys = json.keys() as Array;
    for (var i = 0; i < keys.size(); i++) {
      //System.println(keys[i]);

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
