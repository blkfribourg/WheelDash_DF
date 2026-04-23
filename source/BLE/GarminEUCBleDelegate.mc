using Toybox.BluetoothLowEnergy as Ble;
using Toybox.Application.Storage;
using Toybox.Application.Properties;
import Toybox.Lang;
using Toybox.AntPlus;

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

  var engoDisplayInit = false;
  var cfgList = new [0]b;
  var isUpdatingBleParams as Toybox.Lang.Boolean = false;
  var isBleParamsUpdated as Toybox.Lang.Boolean = false;
  var cfgPacketsTotal = null;
  var cfgPacketsCount = 0;

  var euc_BLE_TX_startTime;
  var BLE_RX_startTime;
  var cmdStacking = null;
  var writeConfigCmd = "FFD00017776865656C64617368000000000500000000AA";
  // engo display strings
  var distUnit = "";
  var spdUnit = "";
  var tempUnit = "";
  function initialize(_decoder) {
    BleDelegate.initialize();
    //char = eucPM.EUC_CHAR;

    decoder = _decoder;
    Ble.setScanState(Ble.SCAN_STATE_SCANNING);
    eucData.isFirst = isFirstConnection();
    //eucData.isFirst = false;
    if (eucData.useRadar == true) {
      eucData.radar = new AntPlus.BikeRadar(null);
    }
  }
  function onCharacteristicWrite(
    characteristic as Toybox.BluetoothLowEnergy.Characteristic,
    status as Toybox.BluetoothLowEnergy.Status
  ) as Void {
    if (eucData.debug) {
      if (BLE_RX_startTime != null) {
        eucData.BLEWriteInterval = System.getTimer() - BLE_RX_startTime;
      }
      BLE_RX_startTime = System.getTimer();
    }
    // _log("onCharacteristicWrite", [characteristic, status]);
    if (characteristic.equals(engo_rx)) {
      if (cfgPacketsTotal != null) {
        cfgUpdateStatus();
      }
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
          eucData.paired = true;
          firstChar = true;
          cccd = euc_char.getDescriptor(Ble.cccdUuid());
          try {
            cccd.requestWrite([0x01, 0x00]b);
          } catch (e instanceof Lang.Exception) {
            // System.println(e.getErrorMessage());
          }
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
          System.println("Engo connected");

          engo_service = device.getService(engoPM.BLE_SERV_ACTIVELOOK);

          if (engo_service != null) {
            engo_tx = engo_service.getCharacteristic(engoPM.BLE_CHAR_TX);
            engo_rx = engo_service.getCharacteristic(engoPM.BLE_CHAR_RX);
            engo_userInput = engo_service.getCharacteristic(engoPM.BLE_CHAR_USERINPUT);
          } else {
            engo_tx = null;
            engo_rx = null;
            engo_userInput = null;
          }

          if (engo_tx != null && engo_rx != null && engo_userInput != null) {
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
        eucData.version = 0;
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
    // resetting profileScanResult if wheelName changed (deleting associated footprint):

    var maxProfile = eucData.profilesNb;
    //   System.println(maxProfile);
    if (maxProfile == 0) {
      // not using Easy config -> max profile number is 3
      maxProfile = 3;
    }
    for (var i = 1; i <= maxProfile; i++) {
      var pName = Properties.getValue("wheelName_p" + i) as String;
      if (!pName.equals(Storage.getValue("profile" + i + "Name"))) {
        //System.println("Deleting profile" + i + "Name");
        Storage.deleteValue("profile" + i + "Sr");
      }
    }

    // If a footprint doesn't exist, return true, else return false
    if (Storage.getValue("profile" + eucData.loadedProfile + "Sr") == null) {
      return true;
    } else {
      return false;
    }
  }

  // This function is used to store the footprint and the EUC name on the persistant storage
  function storeSR(sr) {
    Storage.setValue("profile" + eucData.loadedProfile + "Sr", sr);
    Storage.setValue(
      "profile" + eucData.loadedProfile + "Name",
      Properties.getValue("wheelName_p" + eucData.loadedProfile)
    );
  }

  // This function is used to load the footprint from the persistant storage
  function loadSR() {
    var profileSR = Storage.getValue("profile" + eucData.loadedProfile + "Sr");
    if (profileSR != null) {
      return profileSR;
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
                System.println("EngoFound!");
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
    if (currentChar.equals(euc_char)) {
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
      }if (eucData.wheelBrand ==1){
        if (eucData.version == 0) {
          var storedV = Storage.getValue("profile" + eucData.loadedProfile + "LKVersion");
          if (storedV != null) {
            eucData.version = storedV as Float;
          }
        }
        if (eucData.enableBeep) {
         try {
          var cmd = null;
          if (eucData.version<=3){
cmd=[0x98]b;
          }if (eucData.version>=3 && eucData.version<=7){
cmd = [ 0x4c, 0x6b, 0x41, 0x70, 0x0e, 0x00, 0x80, 0x80, 0x80, 0x01,
                   0xca, 0x87, 0xe6, 0x6f]b;
          }if ( eucData.version>7){
            cmd = [0x4C, 0x64, 0x41, 0x70, 0x0E, 0x00, 0x00, 0x80, 0x80, 0x01, 0xF8, 0x67, 0x9F, 0x85]b;
          }
          System.println("sending beep cmd: "+cmd);
          if (cmd!=null){
        sendRawCmd(euc_char,cmd);
              }
        } catch (e instanceof Lang.Exception) {
          // System.println(e.getErrorMessage());
        }
        }
      }
    } else {
      if (eucData.engoPaired == true) {
        //  System.println("EngoPairedIsTrue, descript");
        //   System.println(engo_userInput);
        //   System.println(engoGestureNotif);
        if (currentChar.equals(engo_userInput) && engoGestureNotif == true) {
          try {
            engo_rx.requestWrite([0xff, 0x06, 0x00, 0x05, 0xaa]b, {
              :writeType => Ble.WRITE_TYPE_DEFAULT,
            });
            //   System.println("send firm req");
          } catch (e instanceof Lang.Exception) {
            System.println(e.getErrorMessage());
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
      /*
      if (eucData.useEngo) {
        if (euc_BLE_TX_startTime != null) {
          eucData.BLEReadInterval = System.getTimer() - euc_BLE_TX_startTime;
        } else {
          euc_BLE_TX_startTime = System.getTimer();
        }
        if (eucData.BLEReadInterval > 500 || eucData.BLEReadInterval < 0) {
          // I don't expect a negative value but if the Sys timer get reset it could happen
          // if more than 500msec after an EUC packet reception, send data to engo
          euc_BLE_TX_startTime = System.getTimer();
          //  engoUpdate();
        }
      }
      
      if (eucData.debug) {
        if (euc_BLE_TX_startTime != null) {
          eucData.BLEReadInterval = System.getTimer() - euc_BLE_TX_startTime;
        }
        euc_BLE_TX_startTime = System.getTimer();
      }*/
      

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
      /*
      if (eucData.debug) {
        eucData.BLEReadProcTime = System.getTimer() - euc_BLE_TX_startTime;
      }*/
    }
    if (char.equals(engo_tx)) {
      //System.println(value);
      //System.println("EngoCharChanged");
      if (value[0] == 0xff) {
        if (value[1] == 0x06) {
          //firmware vers
          if (value.size() > 9) {
            var firm = value.slice(4, 8);
            //System.println("firm: " + firm);
          }

          //req cfg list
          sendRawCmd(engo_rx, [0xff, 0xd3, 0x00, 0x05, 0xaa]b);
        }
        if (value[1] == 0x05) {
          //battery
          eucData.engoBattery = value[4];
        }
        if (value[1] == 0xd3 && value[value.size() - 1] != 0xaa) {
          cfgReadFlag = true;
          // System.println("cfgReadFlagSet");
          //cfg list
          checkCfgName(value);
          return;
        }
      } else {
        // System.println("cfgRead :" + cfgReadFlag);
        if (cfgReadFlag == true && value[value.size() - 1] != 0xaa) {
          //  System.print("reread?");
          checkCfgName(value);
          return;
        }
        if (cfgReadFlag == true && value[value.size() - 1] == 0xaa) {
          System.println("lastcheck");

          checkCfgName(value);
          cfgReadFlag = false;
          //System.println(engoCfgOK);
          if (engoCfgOK != true) {
            //  System.println("wheeldash conf not found");
            engoCfgOK = false;
          }
        }
      }
      if (engoCfgOK == false && cfgPacketsTotal == null) {
        clearScreen();
        sendRawCmd(engo_rx, getWriteCmd("updating config", 195, 110, 4, 5, 16));
        sendRawCmd(engo_rx, getWriteCmd("please wait...", 195, 70, 4, 5, 16));
        cfgPacketsTotal = 0;
        // System.println("received:" + value);
        // System.println("uploading config");

        for (var i = 0; i < getJson(:EngoCfg1).size(); i++) {
          var charNb = getJson(:EngoCfg1)[i].length();
          cfgPacketsTotal = cfgPacketsTotal + Math.ceil(charNb / 40);
          var cmd = arrayToRawCmd(getJson(:EngoCfg1)[i]);

          sendRawCmd(engo_rx, cmd);
        }
        for (var i = 0; i < getJson(:EngoCfg2).size(); i++) {
          var charNb = getJson(:EngoCfg2)[i].length();
          cfgPacketsTotal = cfgPacketsTotal + Math.ceil(charNb / 40);
          var cmd = arrayToRawCmd(getJson(:EngoCfg2)[i]);

          sendRawCmd(engo_rx, cmd);
        }
        for (var i = 0; i < getJson(:EngoCfg3).size(); i++) {
          var charNb = getJson(:EngoCfg3)[i].length();
          cfgPacketsTotal = cfgPacketsTotal + Math.ceil(charNb / 40);
          var cmd = arrayToRawCmd(getJson(:EngoCfg3)[i]);

          sendRawCmd(engo_rx, cmd);
        }
        for (var i = 0; i < getJson(:EngoCfg4).size(); i++) {
          var charNb = getJson(:EngoCfg4)[i].length();
          cfgPacketsTotal = cfgPacketsTotal + Math.ceil(charNb / 40);
          var cmd = arrayToRawCmd(getJson(:EngoCfg4)[i]);

          sendRawCmd(engo_rx, cmd);
        }
        for (var i = 0; i < getJson(:EngoCfg5).size(); i++) {
          var charNb = getJson(:EngoCfg5)[i].length();
          cfgPacketsTotal = cfgPacketsTotal + Math.ceil(charNb / 40);
          var cmd = arrayToRawCmd(getJson(:EngoCfg5)[i]);

          sendRawCmd(engo_rx, cmd);
        }
        for (var i = 0; i < getJson(:EngoCfg6).size(); i++) {
          var charNb = getJson(:EngoCfg6)[i].length();
          cfgPacketsTotal = cfgPacketsTotal + Math.ceil(charNb / 40);
          var cmd = arrayToRawCmd(getJson(:EngoCfg6)[i]);

          sendRawCmd(engo_rx, cmd);
        }
        for (var i = 0; i < getJson(:EngoCfg7).size(); i++) {
          var charNb = getJson(:EngoCfg7)[i].length();
          cfgPacketsTotal = cfgPacketsTotal + Math.ceil(charNb / 40);
          var cmd = arrayToRawCmd(getJson(:EngoCfg7)[i]);

          sendRawCmd(engo_rx, cmd);
        }
        for (var i = 0; i < getJson(:EngoCfg8).size(); i++) {
          var charNb = getJson(:EngoCfg8)[i].length();
          cfgPacketsTotal = cfgPacketsTotal + Math.ceil(charNb / 40);
          var cmd = arrayToRawCmd(getJson(:EngoCfg8)[i]);

          sendRawCmd(engo_rx, cmd);
        }
        for (var i = 0; i < getJson(:EngoCfg9).size(); i++) {
          var charNb = getJson(:EngoCfg9)[i].length();
          cfgPacketsTotal = cfgPacketsTotal + Math.ceil(charNb / 40);
          var cmd = arrayToRawCmd(getJson(:EngoCfg9)[i]);

          sendRawCmd(engo_rx, cmd);
        }
        for (var i = 0; i < getJson(:EngoCfg10).size(); i++) {
          var charNb = getJson(:EngoCfg10)[i].length();
          cfgPacketsTotal = cfgPacketsTotal + Math.ceil(charNb / 40);
          var cmd = arrayToRawCmd(getJson(:EngoCfg10)[i]);

          sendRawCmd(engo_rx, cmd);
        }
        for (var i = 0; i < getJson(:EngoCfg11).size(); i++) {
          var charNb = getJson(:EngoCfg11)[i].length();
          cfgPacketsTotal = cfgPacketsTotal + Math.ceil(charNb / 40);
          var cmd = arrayToRawCmd(getJson(:EngoCfg11)[i]);

          sendRawCmd(engo_rx, cmd);
        }
        for (var i = 0; i < getJson(:EngoCfg12).size(); i++) {
          var charNb = getJson(:EngoCfg12)[i].length();
          cfgPacketsTotal = cfgPacketsTotal + Math.ceil(charNb / 40);
          var cmd = arrayToRawCmd(getJson(:EngoCfg12)[i]);

          sendRawCmd(engo_rx, cmd);
        }
        for (var i = 0; i < getJson(:EngoCfg13).size(); i++) {
          var charNb = getJson(:EngoCfg13)[i].length();
          cfgPacketsTotal = cfgPacketsTotal + Math.ceil(charNb / 40);
          var cmd = arrayToRawCmd(getJson(:EngoCfg13)[i]);

          sendRawCmd(engo_rx, cmd);
        }
        for (var i = 0; i < getJson(:EngoCfg14).size(); i++) {
          var charNb = getJson(:EngoCfg14)[i].length();
          cfgPacketsTotal = cfgPacketsTotal + Math.ceil(charNb / 40);
          var cmd = arrayToRawCmd(getJson(:EngoCfg14)[i]);
          sendRawCmd(engo_rx, cmd);
        }
        if (eucData.customLayout == true) {
          buildCustomPage();
        }
        sendRawCmd(
          engo_rx,
          arrayToRawCmd(writeConfigCmd) //write cfg cmd
        );

        //   System.println("upload ongoing");

        // req Cfg list again;
        cfgList = new [0]b;
        sendRawCmd(engo_rx, [0xff, 0xd3, 0x00, 0x05, 0xaa]b);
      }
      if (engoGestureNotif == true && engoGestureOK == false) {
        if (eucData.engoTouch == 0) {
          sendRawCmd(engo_rx, [0xff, 0x21, 0x00, 0x06, 0x01, 0xaa]b);
        }

        System.println("gesture enabled");
        engoGestureOK = true;
      }
      if (engoCfgOK == true && engoDisplayInit == false) {
        System.println("select cfg");

        eucData.engoCfgUpdate = null;
        EUCAlarms.textAlert = "none";
        //System.println(eucData.engoCfgUpdate);
        sendRawCmd(
          engo_rx,
          [
            0xff, 0xd2, 0x00, 0x0f, 0x77, 0x68, 0x65, 0x65, 0x6c, 0x64, 0x61,
            0x73, 0x68, 0x00, 0xaa,
          ]b
        );
        //
        System.println("clearing screen");
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

    if (char.equals(engo_userInput)) {
      if (value[0] == 0x01) {
        // System.println("gesture detected");
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
    cfgPacketsTotal = null;
    cfgPacketsCount = 0;
    eucData.engoCfgUpdate = null;
  }
  function checkCfgName(value) {
    cfgList.addAll(value);
    //m  System.println("checkNameCfgList: " + cfgList);
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
            var cfgVer = arrayToRawCmd(writeConfigCmd).slice(14, 18);
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
    if (cmdStacking != null) {
      bufferToSend.addAll(cmdStacking);
      cmdStacking = null;
    }
    bufferToSend.addAll(buffer);
    try {
      if (bufferToSend.size() > 20) {
        var sendNow = bufferToSend.slice(0, 20);
        cmdStacking = bufferToSend.slice(20, null);
        _cbCharacteristicWrite = self.method(:__onWrite_finishPayload);
        char.requestWrite(sendNow, {
          :writeType => BluetoothLowEnergy.WRITE_TYPE_WITH_RESPONSE,
        });
      } else if (bufferToSend.size() > 0) {
        char.requestWrite(bufferToSend, {
          :writeType => BluetoothLowEnergy.WRITE_TYPE_WITH_RESPONSE,
        });
      }
    } catch (e instanceof Lang.Exception) {
      // On write error, preserve command for retry
      cmdStacking = bufferToSend;
      rawcmd = null;
      if (eucData.debug) {
        System.println("BLE write error: " + e.getErrorMessage());
      }
    }
  }

  function flushCmdStacking() {
    //  _log("flushCmdStacking",[cmdStacking == null ? 0 : cmdStacking.size()]);
    var indexIncompleteCmd = indexIncompleteCmd() as Toybox.Lang.Number;
    cmdStacking =
      indexIncompleteCmd != 0
        ? cmdStacking.slice(null, indexIncompleteCmd)
        : null;
    resetGraphicEngine();
  }

  function flushCmdStackingIfSup(value as Toybox.Lang.Number) {
    if (cmdStacking != null) {
      if (cmdStacking.size() > value) {
        flushCmdStacking();
      }
    }
  }

  function indexIncompleteCmd() {
    if (cmdStacking) {
      for (var i = 0; i < cmdStacking.size(); i++) {
        if (cmdStacking[i] == 0xaa) {
          if (cmdStacking.size() > i + 1) {
            if (cmdStacking[i + 1] == 0xff) {
              return i + 1;
            }
          }
        }
      }
    }
    return 0;
  }
  function resetGraphicEngine() {
    //   _log("resetGraphicEngine", []);
    holdAndFlush(0xff);
  }

  function holdAndFlush(value) {
    sendRawCmd(engo_rx, commandBuffer(0x39, [value]b));
  }
  function commandBuffer(id, data) {
    var buffer = new [0]b;
    buffer.addAll([0xff, id, 0x00, 0x05 + data.size()]b);
    buffer.addAll(data);
    buffer.add(0xaa);
    //_log("buffer",[buffer]);
    return buffer;
  }

  function cfgUpdateStatus() {
    // means update started

    cfgPacketsCount++;

    eucData.engoCfgUpdate =
      " updt " + ((cfgPacketsCount * 100) / cfgPacketsTotal).toString() + "%";
    if (cfgPacketsCount >= cfgPacketsTotal) {
      //      System.println("done?");
      cfgPacketsTotal = null;
      eucData.engoCfgUpdate = "Loading";
    }
    EUCAlarms.textAlert = "Engo Cfg " + eucData.engoCfgUpdate;
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

  function buildCustomPage() {
    var cmdArray = new [0];

    cmdArray.add(
      saveCustomLayout(22, [0, 0], [117, 40], 3, [84, 34], 34, [89, 3])
    );
    cmdArray.add(
      saveCustomLayout(23, [0, 0], [117, 40], 3, [84, 34], 24, [89, 3])
    );
    cmdArray.add(
      saveCustomLayout(24, [0, 0], [117, 40], 3, [84, 34], 25, [89, 3])
    );
    cmdArray.add(
      saveCustomLayout(25, [0, 0], [117, 40], 3, [84, 34], 31, [89, 3]) //top speed
    );
    cmdArray.add(
      saveCustomLayout(26, [0, 0], [117, 40], 3, [84, 34], 30, [89, 3])
    );
    cmdArray.add(
      saveCustomLayout(27, [0, 0], [117, 40], 3, [84, 34], 35, [89, 3])
    );
    cmdArray.add(
      saveCustomLayout(28, [0, 0], [117, 40], 3, [84, 34], 36, [89, 3])
    );
    cmdArray.add(
      saveCustomLayout(29, [0, 0], [117, 40], 3, [84, 34], 27, [89, 3]) // trip dist ?
    );
    cmdArray.add(
      saveCustomPage(
        3,
        [7, 10, 22, 23, 24, 29, 25, 26, 27, 28], // GPS_SPD,BATT,TEMP,DIST - TOP_SPD,AVG_SPD,CAR_DIST,CAR_SPD
        [
          [152, 205],
          [30, 205],
          [152, 150],
          [152, 110],
          [152, 70],
          [152, 30],
          [30, 150],
          [30, 110],
          [30, 70],
          [30, 30],
        ]
      )
    );
    for (var i = 0; i < cmdArray.size(); i++) {
      var charNb = cmdArray[i].size();
      cfgPacketsTotal = cfgPacketsTotal + Math.ceil(charNb / 20);
      sendRawCmd(engo_rx, cmdArray[i]);
    }
  }
}
