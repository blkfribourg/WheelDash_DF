using Toybox.BluetoothLowEnergy as Ble;
using Toybox.Application.Storage;
import Toybox.Lang;

class eucBLEDelegate extends Ble.BleDelegate {
  var firstChar = null;
  var euc_service = null;
  var euc_char = null;
  var decoder = null;
  var engo_service = null;
  var engo_tx = null;
  var engo_rx = null;
  var engo_userInput = null;
  var engoDevice = null;
  var EUCDevice = null;
  var engoCfgOK;
  var cfgReadFlag = false;
  var engoGestureOK = false;
  var engoGestureNotif = false;
  var _cbCharacteristicWrite = null;
  var rawcmd = null;
  var rawcmdError = null;
  var engoDisplayInit = false;
  var cfgList = new [0]b;
  var isUpdatingBleParams as Toybox.Lang.Boolean = false;
  var isBleParamsUpdated as Toybox.Lang.Boolean = false;
  function initialize(_decoder) {
    BleDelegate.initialize();
    //char = eucPM.EUC_CHAR;

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
        euc_service = device.getService(eucPM.EUC_SERVICE);
        euc_char =
          euc_service != null
            ? euc_service.getCharacteristic(eucPM.EUC_CHAR)
            : null;
        if (euc_service != null && euc_char != null) {
          cccd = euc_char.getDescriptor(Ble.cccdUuid());
          try {
            cccd.requestWrite([0x01, 0x00]b);

            eucData.paired = true;
            firstChar = true;
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
            firstChar = false;
          } catch (e instanceof Lang.Exception) {
            // System.println(e.getErrorMessage());
          }
        }
      }
      if (eucData.useEngo == true) {
        if (device.getService(engoPM.BLE_SERV_ACTIVELOOK) != null) {
          // System.println("Engo connected");

          engo_service = device.getService(engoPM.BLE_SERV_ACTIVELOOK);

          engo_tx =
            engo_service != null
              ? engo_service.getCharacteristic(engoPM.BLE_CHAR_TX)
              : null;

          engo_rx =
            engo_service != null
              ? engo_service.getCharacteristic(engoPM.BLE_CHAR_RX)
              : null;

          engo_userInput =
            engo_service != null
              ? engo_service.getCharacteristic(engoPM.BLE_CHAR_USERINPUT)
              : null;

          if (
            engo_service != null &&
            engo_tx != null &&
            engo_rx != null &&
            engo_userInput != null
          ) {
            // System.println("EngoNotifOn");
            var cccd = engo_tx.getDescriptor(Ble.cccdUuid());
            try {
              cccd.requestWrite([0x01, 0x00]b);
            } catch (e instanceof Lang.Exception) {
              // System.println(e.getErrorMessage());
            }
            eucData.engoPaired = true;
          } else {
            System.print("notif fail");
            try {
              Ble.unpairDevice(device);
              eucData.engoPaired = false;
            } catch (e instanceof Lang.Exception) {
              // System.println(e.getErrorMessage());
            }
          }
        }
      }
    } else {
      if (engoDevice != null && engoDevice.equals(device)) {
        eucData.engoPaired = false;
        //System.println("Engo Disconnected");
        resetEngo();
        try {
          Ble.unpairDevice(device);
        } catch (e instanceof Lang.Exception) {
          // System.println(e.getErrorMessage());
        }
        Ble.setScanState(Ble.SCAN_STATE_SCANNING);
      }
      if (EUCDevice != null && EUCDevice.equals(device)) {
        eucData.paired = false;
        firstChar = false;
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
    // System.println("scanning");
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
              // System.println("EUCError: " + e.getErrorMessage());
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
              // System.println(result.getServiceUuids().next());
              if (
                contains(
                  result.getServiceUuids(),
                  engoPM.BLE_ENGO_MAIN,
                  result
                ) == true
              ) {
                //System.println("EngoFound!");
                Ble.setScanState(Ble.SCAN_STATE_OFF);
                try {
                  // Do something here
                  engoDevice = Ble.pairDevice(result as Ble.ScanResult);
                } catch (e instanceof Lang.Exception) {
                  //   System.println("hornError: " + e.getErrorMessage());
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
        try {
          // Do something here
          EUCDevice = Ble.pairDevice(result as Ble.ScanResult);
        } catch (e instanceof Lang.Exception) {
          // System.println("EUCError: " + e.getErrorMessage());
        }
      }
    }
  }

  function onDescriptorWrite(desc, status) {
    //System.println("UUID:" + desc.getCharacteristic().getUuid());
    var currentChar = desc.getCharacteristic();
    // send getName request for KS using ble queue
    if (currentChar.equals(eucPM.EUC_CHAR)) {
      if (eucData.wheelBrand == 2 || eucData.wheelBrand == 3) {
        try {
          euc_char.requestWrite(
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
    } else {
      if (eucData.engoPaired == true) {
        // System.println("EngoPairedIsTrue, descript");
        if (currentChar.equals(engo_userInput) && engoGestureNotif == true) {
          try {
            engo_rx.requestWrite([0xff, 0x06, 0x00, 0x05, 0xaa]b, {
              :writeType => Ble.WRITE_TYPE_DEFAULT,
            });
          } catch (e instanceof Lang.Exception) {
            // System.println(e.getErrorMessage());
          }
        } else {
          enableGesture();
        }
      }
    }
  }

  function onCharacteristicChanged(char, value) {
    //  System.println("SensorNotif: " + engoGestureNotif);
    // System.println("SensorOK: " + engoGestureOK);

    //   System.println("CharacteristicChanged");
    if (char.equals(euc_char)) {
      if (firstChar == true) {
        // beep
        try {
          euc_char.requestWrite(string_to_byte_array("b" as String), {
            :writeType => Ble.WRITE_TYPE_DEFAULT,
          });
          firstChar = false;
        } catch (e instanceof Lang.Exception) {
          // System.println(e.getErrorMessage());
        }
      }
      //  System.println("EUCCharChanged");
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
      //System.println(value);
      //System.println("EngoCharChanged");
      if (value[1] == 0x06) {
        //firmware vers
        if (value.size() > 9) {
          var firm = value.slice(4, 8);
          //System.println("firm: " + firm);
        }

        //req cfg list
        sendRawCmd(engo_rx, [0xff, 0xd3, 0x00, 0x05, 0xaa]b);
      }
      if (value[0] == 0xff && value[1] == 0x05) {
        //battery
        eucData.engoBattery = value[4];
      }
      if (value[1] == 0xd3 && value[value.size() - 1] != 0xaa) {
        cfgReadFlag = true;
        //cfg list
        checkCfgName(value);
        return;
      }
      if (cfgReadFlag == true && value[value.size() - 1] != 0xaa) {
        checkCfgName(value);
        return;
      }
      if (cfgReadFlag == true && value[value.size() - 1] == 0xaa) {
        checkCfgName(value);
        cfgReadFlag = false;
        if (engoCfgOK != true) {
          //   System.println("wheeldash conf not found");
          engoCfgOK = false;
        }
      }
      if (engoCfgOK == false) {
        clearScreen();
        sendRawCmd(engo_rx, getWriteCmd("updating config", 195, 110, 4, 5, 16));
        sendRawCmd(engo_rx, getWriteCmd("please wait...", 195, 70, 4, 5, 16));
        System.println("uploading config");
        for (var i = 0; i < getJson(:EngoCfg1).size(); i++) {
          var cmd = arrayToRawCmd(getJson(:EngoCfg1)[i]);
          sendRawCmd(engo_rx, cmd);
          //System.println(cmd);
        }
        for (var i = 0; i < getJson(:EngoCfg2).size(); i++) {
          var cmd = arrayToRawCmd(getJson(:EngoCfg2)[i]);
          sendRawCmd(engo_rx, cmd);
          //System.println(cmd);
        }
        //   System.println("upload ongoing");

        // req Cfg list again;
        cfgList = new [0]b;
        sendRawCmd(engo_rx, [0xff, 0xd3, 0x00, 0x05, 0xaa]b);
      }
      if (engoGestureNotif == true && engoGestureOK == false) {
        if (eucData.engoTouch == 0) {
          sendRawCmd(engo_rx, [0xff, 0x21, 0x00, 0x06, 0x01, 0xaa]b);
        }

        //System.println("gesture enabled");
        engoGestureOK = true;
      }
      if (engoCfgOK == true && engoDisplayInit == false) {
        //  System.println("select cfg");
        sendRawCmd(
          engo_rx,
          [
            0xff, 0xd2, 0x00, 0x0f, 0x77, 0x68, 0x65, 0x65, 0x6c, 0x64, 0x61,
            0x73, 0x68, 0x00, 0xaa,
          ]b
        );
        //
        //System.println("clearing screen");
        clearScreen();
        //System.println("displaying page 1");

        /*
        System.println("writing text layout11");
        sendRawCmd(
          engo_rx,
          [
            0xff, 0x37, 0x00, 0x14, 0x00, 0x98, 0x00, 0x80, 0x03, 0x02, 0x0f,
            0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x34, 0x00, 0xaa,
          ]b
        );
*/
        engoDisplayInit = true;
      }
    }
    if (engoDisplayInit == true) {
      //enable gesture
    }
    if (char.equals(engo_userInput)) {
      if (value[0] == 0x01) {
        //System.println("gesture detected");
        eucData.engoPage = eucData.engoPage + 1;
        if (eucData.engoPage > eucData.engoPageNb) {
          eucData.engoPage = 1;
        }
        clearScreen();
      }
    }
  }
  function clearScreen() {
    sendRawCmd(engo_rx, [0xff, 0x01, 0x00, 0x05, 0xaa]b);
    // sendRawCmd(engo_rx, [0xff, 0x86, 0x00, 0x06, eucData.engoPage, 0xaa]b);
  }
  function getEngoBattery() {
    sendRawCmd(engo_rx, [0xff, 0x05, 0x00, 0x05, 0xaa]b);
  }
  function resetEngo() {
    cfgReadFlag = false;
    cfgList = new [0]b;
    engoDisplayInit = false;
    engoCfgOK = null;
    engoGestureOK = false;
    engoGestureNotif = false;
  }
  function checkCfgName(value) {
    cfgList.addAll(value);
    //System.println(cfgList);
    if (cfgList[1] == 0xd3 && cfgList[cfgList.size() - 1] == 0xaa) {
      var names = new [0]b;
      var tempName = new [0]b;
      for (var i = 4; i < cfgList.size(); i++) {
        if (cfgList[i] == 0x00) {
          // dirty fix
          //System.println("config name: " + tempName);
          /*System.println(
            Toybox.StringUtil.convertEncodedString(tempName, {
              :fromRepresentation => Toybox.StringUtil
                .REPRESENTATION_BYTE_ARRAY,
              :toRepresentation => Toybox.StringUtil
                .REPRESENTATION_STRING_PLAIN_TEXT,
            })
          );*/
          if (
            Toybox.StringUtil.convertEncodedString(tempName, {
              :fromRepresentation => Toybox.StringUtil
                .REPRESENTATION_BYTE_ARRAY,
              :toRepresentation => Toybox.StringUtil
                .REPRESENTATION_STRING_PLAIN_TEXT,
            }).equals("wheeldash")
          ) {
            //checking version
            var cfgEngoVer = cfgList.slice(i + 5, i + 9);
            var cfgVer = arrayToRawCmd(
              getJson(:EngoCfg2)[getJson(:EngoCfg2).size() - 2]
            ).slice(14, 18);
            //  System.println(cfgVer);
            //  System.println(cfgEngoVer);
            if (cfgEngoVer.equals(cfgVer)) {
              //    System.println("version is up to date");
              engoCfgOK = true;
            }
          }
          names.addAll(tempName);
          tempName = new [0]b;

          i = i + 11;
        } else {
          tempName.add(cfgList[i]);
        }
      }
      //System.println("config packet: " + cfgList);
    }
  }
  function enableGesture() {
    if (engoGestureNotif == false) {
      try {
        var gcccd = engo_userInput.getDescriptor(Ble.cccdUuid());
        gcccd.requestWrite([0x01, 0x00]b);
        engoGestureNotif = true;
        //  System.println("gesture notif enabled");
      } catch (e) {
        //  System.println("could not enable notif on gesture");
      }
    }
  }

  function sendCommands(cmds) {
    if (engoCfgOK == true && engoDisplayInit == true) {
      sendRawCmd(engo_rx, cmds);
      // System.println(cmds[i]);
    }
  }
  //coder même principe pour descriptor ? ou implementer même methode qu'activelook
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
