using Toybox.BluetoothLowEnergy as Ble;
using Toybox.Application.Storage;
import Toybox.Lang;

class eucBLEDelegate extends Ble.BleDelegate {
  var device = null;
  var service = null;
  var char = null;
  var decoder = null;
  var engo_service = null;
  var engo_tx = null;
  var engo_rx = null;
  var engoDevice = null;
  var EUCDevice = null;
  var engoCfgOK;
  var cfgReadFlag = false;
  var _cbCharacteristicWrite = null;
  var rawcmd = null;
  var rawcmdError = null;

  var isUpdatingBleParams as Toybox.Lang.Boolean = false;
  var isBleParamsUpdated as Toybox.Lang.Boolean = false;
  function initialize(_decoder) {
    BleDelegate.initialize();
    char = eucPM.EUC_CHAR;

    decoder = _decoder;

    Ble.setScanState(Ble.SCAN_STATE_SCANNING);
    eucData.isFirst = isFirstConnection();
    eucData.isFirst = false;
    if (eucData.useRadar == true) {
      eucData.radar = new AntPlus.BikeRadar(null);
    }
  }
  function onCharacteristicWrite(
    characteristic as Toybox.BluetoothLowEnergy.Characteristic,
    status as Toybox.BluetoothLowEnergy.Status
  ) as Void {
    // _log("onCharacteristicWrite", [characteristic, status]);
    if (isUpdatingBleParams && !isBleParamsUpdated) {
      isUpdatingBleParams = false;
      if (status == Toybox.BluetoothLowEnergy.STATUS_SUCCESS) {
        isBleParamsUpdated = true;
      }
    } else {
      // TODO: Refactor to avoid callback like this
      var _cb = _cbCharacteristicWrite;
      if (_cb != null) {
        _cb.invoke(characteristic, status);
      }
    }
  }
  function onConnectedStateChanged(device, state) {
    //		view.deviceStatus=state;
    if (state == Ble.CONNECTION_STATE_CONNECTED) {
      if (device.getService(eucPM.EUC_SERVICE) != null) {
        var cccd;
        service = device.getService(eucPM.EUC_SERVICE);
        char =
          service != null ? service.getCharacteristic(eucPM.EUC_CHAR) : null;
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
      }
      if (eucData.useEngo == true) {
        if (device.getService(engoPM.BLE_SERV_ACTIVELOOK) != null) {
          System.println("Horn connected");

          engo_service = device.getService(engoPM.BLE_SERV_ACTIVELOOK);

          engo_tx =
            engo_service != null
              ? engo_service.getCharacteristic(engoPM.BLE_CHAR_TX)
              : null;

          engo_rx =
            engo_service != null
              ? engo_service.getCharacteristic(engoPM.BLE_CHAR_RX)
              : null;

          if (engo_service != null && engo_tx != null && engo_rx != null) {
            var cccd = engo_tx.getDescriptor(Ble.cccdUuid());
            cccd.requestWrite([0x01, 0x00]b);

            eucData.engoPaired = true;
          } else {
            System.print("notif fail");
            Ble.unpairDevice(device);
            eucData.engoPaired = false;
          }
        }
      }
    } else {
      if (engoDevice != null && engoDevice.equals(device)) {
        eucData.engoPaired = false;

        try {
          Ble.unpairDevice(device);
        } catch (e instanceof Lang.Exception) {
          // System.println(e.getErrorMessage());
        }
        Ble.setScanState(Ble.SCAN_STATE_SCANNING);
      }
      if (EUCDevice != null && EUCDevice.equals(device)) {
        eucData.paired = false;

        try {
          Ble.unpairDevice(device);
        } catch (e instanceof Lang.Exception) {
          // System.println(e.getErrorMessage());
        }
        Ble.setScanState(Ble.SCAN_STATE_SCANNING);
      }
      //BLE Disconnected
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
    System.println("scanning");
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
            try {
              EUCDevice = Ble.pairDevice(result as Ble.ScanResult);
            } catch (e instanceof Lang.Exception) {
              System.println("EUCError: " + e.getErrorMessage());
            }
          }
        }
      }
    } else {
      if (eucData.useEngo == true) {
        if (eucData.engoPaired == false) {
          for (
            var result = scanResults.next();
            result != null;
            result = scanResults.next()
          ) {
            if (result instanceof Ble.ScanResult) {
              System.println(result.getServiceUuids().next());
              if (
                contains(
                  result.getServiceUuids(),
                  engoPM.BLE_ENGO_MAIN,
                  result
                ) == true
              ) {
                System.println("HornFOund!");
                Ble.setScanState(Ble.SCAN_STATE_OFF);
                try {
                  // Do something here
                  engoDevice = Ble.pairDevice(result as Ble.ScanResult);
                } catch (e instanceof Lang.Exception) {
                  System.println("hornError: " + e.getErrorMessage());
                }
                //System.println("ConnectedToHorn?");
              }
            }
          }
        }
      } else {
        Ble.setScanState(Ble.SCAN_STATE_OFF);
      }

      var result = loadSR();
      if (result != false) {
        //        EUCDevice = Ble.pairDevice(result as Ble.ScanResult);
      }
    }
  }

  function onDescriptorWrite(desc, status) {
    var currentChar = desc.getCharacteristic();
    // send getName request for KS using ble queue
    if (currentChar.equals(eucPM.EUC_CHAR)) {
      if (eucData.wheelBrand == 2 || eucData.wheelBrand == 3) {
        char.requestWrite(
          [
            0xaa, 0x55, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x9b, 0x14, 0x5a, 0x5a,
          ]b,
          { :writeType => Ble.WRITE_TYPE_DEFAULT }
        );
      }
    }
    if (currentChar.equals(engo_tx)) {
      System.println("desc succ written");
      engo_rx.requestWrite([0xff, 0x06, 0x00, 0x05, 0xaa]b, {
        :writeType => Ble.WRITE_TYPE_DEFAULT,
      });
    }
  }

  function onCharacteristicChanged(char, value) {
    // message7 = "CharacteristicChanged";
    if (char.equals(eucPM.EUC_CHAR)) {
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
    if (char.equals(engo_tx)) {
      if (value[1] == 0x06) {
        //firmware vers
        if (value.size() > 9) {
          var firm = value.slice(4, 8);
          System.println(firm);
        }
        //req cfg list
        engo_rx.requestWrite([0xff, 0xd3, 0x00, 0x05, 0xaa]b, {
          :writeType => Ble.WRITE_TYPE_DEFAULT,
        });
      }
      if (value[1] == 0xd3 && value[value.size() - 1] != 0xaa) {
        cfgReadFlag = true;
        //cfg list
        checkCfgName(value);
      }
      if (cfgReadFlag == true && value[value.size() - 1] != 0xaa) {
        checkCfgName(value);
      }
      if (cfgReadFlag == true && value[value.size() - 1] == 0xaa) {
        checkCfgName(value);
        cfgReadFlag = false;
        if (engoCfgOK != true) {
          System.println("wheeldash conf not found");
          engoCfgOK = false;
        }
      }
      if (engoCfgOK == false) {
        System.println("uploading config");
        for (var i = 0; i < cfgArray.size(); i++) {
          var cmd = arrayToRawCmd(cfgArray, i);
          sendRawCmd(engo_rx, cmd);
          System.println(cmd);
        }
        System.println("upload done");
        engoCfgOK = true;
      }
      if (engoCfgOK == true) {
        System.println("select cfg");
        sendRawCmd(
          engo_rx,
          [
            0xff, 0xd2, 0x00, 0x0f, 0x77, 0x68, 0x65, 0x65, 0x6c, 0x64, 0x61,
            0x73, 0x68, 0x00, 0xaa,
          ]b
        );
        //sendRawCmd(engo_rx, [0xff, 0x01, 0x00, 0x05, 0x0a]b);
        System.println("displaying page 1");
        sendRawCmd(
          engo_rx,
          [
            0xff, 0x86, 0x00, 0x0e, 0x01, 0x01, 0x00, 0x01, 0x00, 0x01, 0x00,
            0x01, 0x00, 0xaa,
          ]b
        );
      }
    }
  }

  function checkCfgName(value) {
    System.println("config packets: " + value);
    if (value.size() > 9) {
      var cfg_name = value.slice(0, 9);
      System.println("config name: " + cfg_name);
      if (
        cfg_name ==
        [0x77, 0x68, 0x65, 0x65, 0x6c, 0x64, 0x61, 0x73, 0x68, 0x00]b
      ) {
        engoCfgOK = true;
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

  function sendRawCmd(char, buffer) {
    var bufferToSend = []b;
    if (rawcmdError != null) {
      bufferToSend.addAll(rawcmdError);
      rawcmdError = null;
    }
    bufferToSend.addAll(buffer);
    try {
      if (bufferToSend.size() > 20) {
        var sendNow = bufferToSend.slice(0, 20);
        rawcmdError = bufferToSend.slice(20, null);
        _cbCharacteristicWrite = self.method(:__onWrite_finishPayload);
        char.requestWrite(sendNow, {
          :writeType => BluetoothLowEnergy.WRITE_TYPE_WITH_RESPONSE,
        });
      } else if (bufferToSend.size() > 0) {
        char.requestWrite(bufferToSend, {
          :writeType => BluetoothLowEnergy.WRITE_TYPE_WITH_RESPONSE,
        });
      }
    } catch (e) {
      rawcmdError = bufferToSend;
      rawcmd = null;
      // onBleError(e);
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
  function __onWrite_finishPayload(c, s) {
    _cbCharacteristicWrite = null;
    if (s == 0) {
      self.sendRawCmd(c, []b);
    } else {
      throw new Toybox.Lang.InvalidValueException("(E) Could write on: " + c);
    }
  }
  var shouldAdd;

  function getChar() {
    return char;
  }

  function manualUnpair() {
    if (device != null) {
      Ble.unpairDevice(device);
    }
  }
  function stringToPadByteArray(str, size, leftPadding) {
    var result = StringUtil.convertEncodedString(str, {
      :fromRepresentation => StringUtil.REPRESENTATION_STRING_PLAIN_TEXT,
      :toRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY,
      :encoding => StringUtil.CHAR_ENCODING_UTF8,
    });
    if (size) {
      var padSize = size - result.size();
      if (padSize > 0) {
        var padBuffer = []b;
        do {
          padBuffer.add(0x20);
          padSize -= 1;
        } while (padSize > 0);
        if (leftPadding) {
          padBuffer.addAll(result);
          result = padBuffer;
        } else {
          result.addAll(padBuffer);
        }
      }
    }
    result.add(0x00);
    return result;
  }
}
