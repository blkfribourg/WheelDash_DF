import Toybox.Communications;
import Toybox.System;
import Toybox.Lang;

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
  function setSettings(json) {
    if (json != null) {
      Storage.setValue("JSONSettings", json);
      System.println("writing json to local storage"); // saving json to appstorage:
    }

    eucData.settingsChanged = true;
  }
  function settingsChanged(json as Dictionary) {
    // checking if a stored JSON exists :
    var storedJSON = Storage.getValue("JSONSettings") as Dictionary;
    //if stored JSON exists and is the same as the new one, return false

    //System.print(settings);

    if (storedJSON != null) {
      System.println("Existing localJSON");

      if (compareJSON(storedJSON, json) == true) {
        System.println("same");
        return false;
      } else {
        // Storage.setValue("JSONSettings", json);
        System.println("diff");
        return true;
      }
    } else {
      System.println("no localJSON detected");
      Storage.setValue("JSONSettings", json);

      return false;
    }
  }

  public function onReceive(
    responseCode as Number,
    data as Dictionary<String, Object?> or String or Null
  ) as Void {
    System.println(responseCode);
    System.println(data);
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
    // if jsons are identical returns true, else returns false

    var keys1 = json1.keys() as Array;
    var keys2 = json2.keys() as Array;
    if (keys1.size() != keys2.size()) {
      return false;
    }
    //System.println(keys1.size());
    for (var i = 0; i < keys1.size(); i++) {
      var firstLvl = json1.get(keys1[i]) as Dictionary;
      if (firstLvl instanceof Dictionary) {
        var secondLvlKeys = firstLvl.keys();
        for (var j = 0; j < secondLvlKeys.size(); j++) {
          // System.println(secondLvlKeys);
          if (secondLvlKeys instanceof Array) {
            var thirdLvl = firstLvl.get(secondLvlKeys[j]);

            if (thirdLvl instanceof Dictionary) {
              var thirdLvlKeys = thirdLvl.keys();
              if (thirdLvlKeys instanceof Array) {
                for (var k = 0; k < thirdLvlKeys.size(); k++) {
                  var value1 = (
                    (json1.get(keys1[i]) as Dictionary).get(secondLvlKeys[j]) as
                      Dictionary
                  ).get(thirdLvlKeys[k]);
                  var value2 = (
                    (json2.get(keys1[i]) as Dictionary).get(secondLvlKeys[j]) as
                      Dictionary
                  ).get(thirdLvlKeys[k]);

                  if (!value1.equals(value2)) {
                    //System.println("keys " + keys1[i] + " are different");
                    return false;
                  }
                }
              }
            }
          }
          //  System.println(secondLvl);
        }
      } else {
        var value1 = json1.get(keys1[i]);
        var value2 = json2.get(keys1[i]);

        if (!value1.equals(value2)) {
          //System.println("keys " + keys1[i] + " are different");
          return false;
        }
      }
    }
    return true;
  }
}
