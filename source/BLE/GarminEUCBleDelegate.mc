using Toybox.BluetoothLowEnergy as Ble;
using Toybox.Application.Storage;
import Toybox.WatchUi;
import Toybox.Lang;
using Toybox.AntPlus;
class eucBLEDelegate extends Ble.BleDelegate {
  var device = null;
  var service = null;
  var char = null;
  var char_w = null;
  var decoder = null;
  var lastPacketType;
  var radar;

  // patton packet
  /*
  var frame1 = [
    0xdc, 0x5a, 0x5c, 0x45, 0x2a, 0xbe, 0x00, 0x00, 0x3e, 0xdc, 0x00, 0x00,
    0x85, 0x62, 0x00, 0x35, 0x00, 0x00, 0x0b, 0x5c,
  ]b;
  var frame2 = [
    0x0d, 0xfe, 0x00, 0x00, 0x02, 0xbc, 0x07, 0xd0, 0x0f, 0xac, 0x00, 0x02,
    0x19, 0xfb, 0x00, 0x00, 0x00, 0x6f, 0x00, 0x00,
  ]b;
  var frame3 = [
    0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x04, 0x00, 0x00, 0x14, 0xff, 0xff,
    0xff, 0xff, 0xff, 0x32, 0xee, 0x02, 0x91, 0x09,
  ]b;
  var frame4 = [
    0xdf, 0x0f, 0xd3, 0x03, 0xcb, 0x00, 0x00, 0x00, 0x00, 0x6f, 0x9a, 0x79,
    0xc2,
  ]b;
  */
  /*
  // Lynx packet
  var frame1 = [
    0xdc, 0x5a, 0x5c, 0x53, 0x39, 0x1b, 0x00, 0x00, 0x06, 0xd0, 0x00, 0x00,
    0x07, 0x70, 0x00, 0x00, 0x00, 0x26, 0x0b, 0xcc,
  ]b;
  var frame2 = [
    0x0e, 0x08, 0x00, 0x00, 0x00, 0xfa, 0x00, 0xc8, 0x13, 0x8c, 0x00, 0xb4,
    0x00, 0x0b, 0x01, 0x4c, 0x80, 0xc8, 0x00, 0x00,
  ]b;
  var frame3 = [
    0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x01, 0x00, 0x08, 0x80, 0x80, 0x80,
    0x80, 0x0f, 0xee, 0x0f, 0xee, 0x0f, 0xee, 0x0f,
  ]b;
  var frame4 = [
    0xee, 0x0f, 0xef, 0x0f, 0xe8, 0x0f, 0xef, 0x0f, 0xef, 0x0f, 0xf0, 0x0f,
    0xf0, 0x0f, 0xf0, 0x0f, 0xea, 0x0f, 0xef, 0x0f,
  ]b;
  var frame5 = [0xef, 0x0f, 0xef, 0xda, 0xb2, 0x25, 0x18]b;
*/

  //  KS packets
  /*
  var frame1 = [
    0xaa, 0x55, 0x4b, 0x53, 0x2d, 0x53, 0x31, 0x38, 0x2d, 0x30, 0x32, 0x30,
    0x35, 0x00, 0x00, 0x00, 0xbb, 0x14, 0x84, 0xfd,
  ]b;
  var frame2 = [
    0xaa, 0x55, 0x69, 0x19, 0x03, 0x02, 0x00, 0x00, 0x9f, 0x36, 0xd7, 0x00,
    0x14, 0x05, 0x00, 0xe0, 0xa9, 0x14, 0x5a, 0x5a,
  ]b;
  var frame3 = [
    0xaa, 0x55, 0x00, 0x00, 0x09, 0x00, 0x17, 0x01, 0x15, 0x02, 0x14, 0x01,
    0x00, 0x00, 0x40, 0x06, 0xb9, 0x14, 0x5a, 0x5a,
  ]b;
  var frame4 = [
    0xaa, 0x55, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x40, 0x0c, 0xf5, 0x14, 0x5a, 0x5a,
  ]b;

  var frame5 = [
    0xaa, 0x55, 0x85, 0x0c, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x16, 0x00, 0x00, 0x00, 0xf6, 0x14, 0x5a, 0x5a,
  ]b;
  */
  function initialize(_decoder) {
    BleDelegate.initialize();
    char = eucPM.EUC_CHAR;

    decoder = _decoder;

    Ble.setScanState(Ble.SCAN_STATE_SCANNING);
    eucData.isFirst = isFirstConnection();
    if (eucData.useRadar == true) {
      radar = new AntPlus.BikeRadar(null);
    }
  }

  function onConnectedStateChanged(device, state) {
    //		view.deviceStatus=state;
    if (state == Ble.CONNECTION_STATE_CONNECTED) {
      var cccd;
      service = device.getService(eucPM.EUC_SERVICE);
      char = service != null ? service.getCharacteristic(eucPM.EUC_CHAR) : null;
      char_w =
        service != null ? service.getCharacteristic(eucPM.EUC_CHAR_W) : null;
      if (service != null && char != null) {
        cccd = char.getDescriptor(Ble.cccdUuid());
        cccd.requestWrite([0x01, 0x00]b);

        eucData.paired = true;

        //        eucData.timeWhenConnected = new Time.Moment(Time.now().value());

        /* NOT WORKING
        if (device.getName() != null || device.getName().length != 0) {
          eucData.name = device.getName();
        } else {
          eucData.name = "Unknown";
        }*/
      } else {
        Ble.unpairDevice(device);
        eucData.paired = false;
      }
    } else {
      Ble.unpairDevice(device);
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
          if (eucData.wheelBrand == 4 || eucData.wheelBrand == 5) {
            // V11 or V12 only for now

            var advName = result.getDeviceName();
            if (advName != null) {
              var advModel = advName.substring(0, 3);
              if (
                advModel.equals("V11") ||
                advModel.equals("V12") ||
                advModel.equals("V13") ||
                advModel.equals("V14")
              ) {
                eucData.model = advModel;
                wheelFound = true;
              }
            }
          }
          if (eucData.wheelBrand == 6) {
            // V11 only for now
            var advName = result.getDeviceName();
            if (advName != null) {
              if (advName.substring(0, 4).equals("VESC")) {
                wheelFound = true;
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
      char.requestWrite(
        [
          0xaa, 0x55, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x9b, 0x14, 0x5a, 0x5a,
        ]b,
        { :writeType => Ble.WRITE_TYPE_DEFAULT }
      );
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
    if (decoder != null && eucData.wheelBrand == 4) {
      decoder.frameBuffer(self, value);
    }
    if (decoder != null && eucData.wheelBrand == 5) {
      decoder.frameBuilder(self, value);
    }
    /*
    if (eucData.useRadar == true) {
      var toneProfile = [new Attention.ToneProfile(500, 200)];

      if (Attention has :ToneProfile) {
        Attention.playTone({ :toneProfile => toneProfile });
      }
    }*/

    if (eucData.useRadar == true && radar != null) {
      eucData.variaConnected = true;
      var target = radar.getRadarInfo();
      if (target.size() != 0) {
        Varia.processTarget(target);
      }
    }
  }

  function sendCmd(cmd) {
    //Sys.println("enter sending command " + cmd);

    if (service != null && char != null && cmd != "") {
      var enc_cmd = string_to_byte_array(cmd as String);
      // Sys.println("sending command " + enc_cmd.toString());
      char.requestWrite(enc_cmd, { :writeType => Ble.WRITE_TYPE_DEFAULT });
      //  Sys.println("command sent !");
    }
  }

  function sendRawCmd(cmd) {
    //Sys.println("enter sending command " + cmd);
    char.requestWrite(cmd, { :writeType => Ble.WRITE_TYPE_DEFAULT });
    //  Sys.println("command sent !");
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

  function getChar() {
    return char;
  }

  function manualUnpair() {
    if (device != null) {
      Ble.unpairDevice(device);
    }
  }

  function IM_VESC_reqLiveData() {
    // inmotion
    if (eucData.wheelBrand == 4 || eucData.wheelBrand == 5) {
      try {
        char_w.requestWrite([0xaa, 0xaa, 0x14, 0x01, 0x04, 0x11]b, {
          :writeType => Ble.WRITE_TYPE_DEFAULT,
        });
      } catch (e instanceof Lang.Exception) {}
    }
    // VESC
    if (eucData.wheelBrand == 6) {
      try {
        char.requestWrite([0x02, 0x01, 0x2f, 0xd5, 0x8d, 0x03]b, {
          :writeType => Ble.WRITE_TYPE_DEFAULT,
        });
      } catch (e instanceof Lang.Exception) {}
    }
  }
  function IM_reqStats() {
    try {
      char_w.requestWrite([0xaa, 0xaa, 0x14, 0x01, 0x11, 0x04]b, {
        :writeType => Ble.WRITE_TYPE_DEFAULT,
      });
    } catch (e instanceof Lang.Exception) {}
  }
}
