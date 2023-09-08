using Toybox.BluetoothLowEnergy as Ble;

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
  }

  function onConnectedStateChanged(device, state) {
    if (state == Ble.CONNECTION_STATE_CONNECTED) {
      var cccd;
      service = device.getService(eucPM.EUC_SERVICE);
      char = service != null ? service.getCharacteristic(eucPM.EUC_CHAR) : null;
      if (service != null && char != null) {
        cccd = char.getDescriptor(Ble.cccdUuid());
        cccd.requestWrite([0x01, 0x00]b);
        eucData.paired = true;
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

  //! @param scanResults An iterator of new scan results
  function onScanResults(scanResults as Ble.Iterator) {
    var wheelFound = false;
    for (
      var result = scanResults.next();
      result != null;
      result = scanResults.next()
    ) {
      if (result instanceof Ble.ScanResult) {
        if (
          eucData.wheelBrand == 0 ||
          eucData.wheelBrand == 1 ||
          eucData.wheelBrand == 3
        ) {
          wheelFound = contains(
            result.getServiceUuids(),
            eucPM.EUC_SERVICE,
            result
          );
        }
        if (eucData.wheelBrand == 2) {
          var advName = result.getDeviceName();
          if (advName != null) {
            if (advName.substring(0, 3).equals("KSN")) {
              wheelFound = true;
            }
          }
        }
        if (wheelFound == true) {
          Ble.setScanState(Ble.SCAN_STATE_OFF);
          device = Ble.pairDevice(result);
        }
      }
    }
  }

  function onDescriptorWrite(desc, status) {
    // send getName request for KS using ble queue
    if (eucData.wheelBrand == 2 && char != null) {
      //decoder.requestName();
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
      (eucData.wheelBrand == 0 ||
        eucData.wheelBrand == 1 ||
        eucData.wheelBrand == 3)
    ) {
      decoder.frameBuffer(value);
    }
    if (decoder != null && eucData.wheelBrand == 2) {
      decoder.processFrame(value);
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

  function getChar() {
    return char;
  }
}
