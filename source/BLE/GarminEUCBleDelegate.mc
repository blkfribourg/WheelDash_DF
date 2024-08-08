using Toybox.BluetoothLowEnergy as Ble;
using Toybox.Application.Storage;
import Toybox.Lang;

class eucBLEDelegate extends Ble.BleDelegate {
  var device = null;
  var service = null;
  var char = null;
  var decoder = null;

  function initialize(_decoder) {
    BleDelegate.initialize();
    char = eucPM.EUC_CHAR;

    decoder = _decoder;

    Ble.setScanState(Ble.SCAN_STATE_SCANNING);
    eucData.isFirst = isFirstConnection();
    if (eucData.useRadar == true) {
      eucData.radar = new AntPlus.BikeRadar(null);
    }
  }

  function onConnectedStateChanged(device, state) {
    //		view.deviceStatus=state;
    if (state == Ble.CONNECTION_STATE_CONNECTED) {
      var cccd;
      service = device.getService(eucPM.EUC_SERVICE);
      char = service != null ? service.getCharacteristic(eucPM.EUC_CHAR) : null;
      if (service != null && char != null) {
        cccd = char.getDescriptor(Ble.cccdUuid());

        try {
          cccd.requestWrite([0x01, 0x00]b);
          eucData.paired = true;
        } catch (e instanceof Lang.Exception) {
          // System.println(e.getErrorMessage());
        }
        //        eucData.timeWhenConnected = new Time.Moment(Time.now().value());

        /* NOT WORKING
        if (device.getName() != null || device.getName().length != 0) {
          eucData.name = device.getName();
        } else {
          eucData.name = "Unknown";
        }*/
      } else {
        try {
          Ble.unpairDevice(device);
          eucData.paired = false;
        } catch (e instanceof Lang.Exception) {
          // System.println(e.getErrorMessage());
        }
      }
    } else {
      try {
        Ble.unpairDevice(device);
      } catch (e instanceof Lang.Exception) {
        // System.println(e.getErrorMessage());
      }
      Ble.setScanState(Ble.SCAN_STATE_SCANNING);
      eucData.paired = false;
    }
  }
  function isFirstConnection() {
    // resetting profileScanResult if wheelName changed :
    if (
      !AppStorage.getSetting("wheelName_p1").equals(
        Storage.getValue("profile1Name")
      )
    ) {
      Storage.deleteValue("profile1Sr");
    }
    if (
      !AppStorage.getSetting("wheelName_p2").equals(
        Storage.getValue("profile2Name")
      )
    ) {
      Storage.deleteValue("profile2Sr");
    }
    if (
      !AppStorage.getSetting("wheelName_p3").equals(
        Storage.getValue("profile3Name")
      )
    ) {
      Storage.deleteValue("profile3Sr");
    }

    if (eucData.profile == 1 && Storage.getValue("profile1Sr") == null) {
      return true;
    } else if (eucData.profile == 2 && Storage.getValue("profile2Sr") == null) {
      return true;
    } else if (eucData.profile == 3 && Storage.getValue("profile3Sr") == null) {
      return true;
    } else {
      return false;
    }
  }

  function storeSR(sr) {
    if (eucData.profile == 1) {
      Storage.setValue("profile1Sr", sr);
      Storage.setValue("profile1Name", AppStorage.getSetting("wheelName_p1"));
    } else if (eucData.profile == 2) {
      Storage.setValue("profile2Sr", sr);
      Storage.setValue("profile2Name", AppStorage.getSetting("wheelName_p2"));
    } else if (eucData.profile == 3) {
      Storage.setValue("profile3Sr", sr);
      Storage.setValue("profile3Name", AppStorage.getSetting("wheelName_p3"));
    }
  }
  function loadSR() {
    if (eucData.profile == 1) {
      return Storage.getValue("profile1Sr");
    } else if (eucData.profile == 2) {
      return Storage.getValue("profile2Sr");
    } else if (eucData.profile == 3) {
      return Storage.getValue("profile3Sr");
    } else {
      return false;
    }
  }
  //! @param scanResults An iterator of new scan results
  function onScanResults(scanResults as Ble.Iterator) {
    if (eucData.isFirst) {
      var wheelFound = false;
      for (
        var result = scanResults.next();
        result != null;
        result = scanResults.next()
      ) {
        if (result instanceof Ble.ScanResult) {
          if (eucData.wheelBrand == 0 || eucData.wheelBrand == 1) {
            wheelFound = contains(
              result.getServiceUuids(),
              eucPM.EUC_SERVICE,
              result
            );
          }
          if (eucData.wheelBrand == 3 && eucPM.OLD_KS_ADV_SERVICE != null) {
            wheelFound = contains(
              result.getServiceUuids(),
              eucPM.OLD_KS_ADV_SERVICE,
              result
            );
          }
          if (eucData.wheelBrand == 2) {
            var advName = result.getDeviceName();
            if (advName != null) {
              if (advName.substring(0, 3).equals("KSN")) {
                wheelFound = true;
                //decoder.setBleDelegate(self);
                //decoder.setQueue(queue);
              }
            }
          }
          if (wheelFound == true) {
            storeSR(result);
            Ble.setScanState(Ble.SCAN_STATE_OFF);
            device = Ble.pairDevice(result as Ble.ScanResult);
          }
        }
      }
    } else {
      Ble.setScanState(Ble.SCAN_STATE_OFF);
      var result = loadSR();
      if (result != false) {
        device = Ble.pairDevice(result as Ble.ScanResult);
      }
    }
  }

  function onDescriptorWrite(desc, status) {
    // send getName request for KS using ble queue
    if ((eucData.wheelBrand == 2 || eucData.wheelBrand == 3) && char != null) {
      try {
        char.requestWrite(
          [
            0xaa, 0x55, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x9b, 0x14, 0x5a, 0x5a,
          ]b,
          { :writeType => Ble.WRITE_TYPE_DEFAULT }
        );
      } catch (e instanceof Lang.Exception) {
        // System.println(e.getErrorMessage());
      }
    }
  }

  function onCharacteristicWrite(desc, status) {}

  function onCharacteristicChanged(char, value) {
    // message7 = "CharacteristicChanged";
    if (
      decoder != null &&
      (eucData.wheelBrand == 0 || eucData.wheelBrand == 1)
    ) {
      decoder.frameBuffer(value);
    }
    if (
      decoder != null &&
      (eucData.wheelBrand == 2 || eucData.wheelBrand == 3)
    ) {
      decoder.processFrame(value);
    }
    EUCAlarms.checkAlarms();
    if (
      eucData.useRadar == true &&
      eucData.radar != null &&
      eucData.timerState == 3
    ) {
      try {
        Varia.processTarget(eucData.radar.getRadarInfo()); // surrounding by try because varia may disconnect (unexpected crashes were observed)
      } catch (e instanceof Lang.Exception) {
        // System.println(e.getErrorMessage());
      }
    }
  }

  private function contains(iter, obj, sr) {
    for (var uuid = iter.next(); uuid != null; uuid = iter.next()) {
      if (uuid.equals(obj)) {
        return true;
      }
    }
    return false;
  }
  /*
    hidden function string_to_byte_array(plain_text) {
    var options = {
		:fromRepresentation => StringUtil.REPRESENTATION_STRING_PLAIN_TEXT,
        :toRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY,
        :encoding => StringUtil.CHAR_ENCODING_UTF8
    };
    
    //System.println(Lang.format("Converting '$1$' to ByteArray", [ plain_text ]));
    var result = StringUtil.convertEncodedString(plain_text, options);
    //System.println(Lang.format("           '$1$'..", [ result ]));
    
    return result;
}
*/

  var shouldAdd;

  function getChar() {
    return char;
  }

  function manualUnpair() {
    if (device != null) {
      try {
        Ble.unpairDevice(device);
      } catch (e instanceof Lang.Exception) {
        // System.println(e.getErrorMessage());
      }
    }
  }
}
