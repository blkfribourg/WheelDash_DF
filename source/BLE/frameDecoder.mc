import Toybox.Lang;
using Toybox.BluetoothLowEnergy as Ble;

module frameDecoder {
  function init() {
    if (eucData.wheelBrand == 0) {
      return new GwDecoder();
    }
    if (eucData.wheelBrand == 1) {
      return new VeteranDecoder();
    }
    if (eucData.wheelBrand == 2) {
      return new KingsongDecoder();
    } else {
      return null;
    }
  }
}

class GwDecoder {
  function signedShortFromBytesBE(bytes, starting) {
    if (bytes.size() >= starting + 2) {
      return (
        ((((bytes[starting] & 0xff) << 8) | bytes[starting + 1]) << 16) >> 16
      );
    }
    return 0;
  }

  function shortFromBytesBE(bytes, starting) {
    if (bytes.size() >= starting + 2) {
      return (
        ((((bytes[starting] & 0xff) << 8) | (bytes[starting + 1] & 0xff)) <<
          16) >>
        16
      );
    }
    return 0;
  }

  function UInt32FromBytesBE(bytes, starting) {
    if (bytes.size() >= starting + 4) {
      return (
        ((bytes[starting] & 0xff) << 24) |
        ((bytes[starting + 1] & 0xff) << 16) |
        ((bytes[starting + 2] & 0xff) << 8) |
        (bytes[starting + 3] & 0xff)
      );
    }
    return 0;
  }

  function frameBuffer(transmittedFrame) {
    for (var i = 0; i < transmittedFrame.size(); i++) {
      if (checkChar(transmittedFrame[i]) == true) {
        // process frame and guess type
        if (frame[18].toNumber() == 0) {
          // Frame A
          //System.println("Frame A detected");
          processFrameA(frame);
        } else if (frame[18].toNumber() == 4) {
          // Frame B
          //System.println("Frame B detected");
          processFrameB(frame);
        }
      }
    }
  }

  // adapted from wheellog
  var oldc;
  var frame as ByteArray?;
  var state = "unknown";
  function checkChar(c) {
    if (state.equals("collecting") && frame != null) {
      frame.add(c);
      oldc = c;

      var size = frame.size();

      if (
        (size == 20 && c.toNumber() != 24) ||
        (size > 20 && size <= 24 && c.toNumber() != 90)
      ) {
        state = "unknown";
        return false;
      }

      if (size == 24) {
        state = "done";
        return true;
      }
    } else {
      if (oldc != null && oldc.toNumber() == 85 && c.toNumber() == 170) {
        // beguining of a frame
        frame = new [0]b;
        frame.add(85);
        frame.add(170);
        state = "collecting";
      }
      oldc = c;
    }
    return false;
  }

  function processFrameB(value) {
    eucData.totalDistance = UInt32FromBytesBE(value, 2) / 1000.0; // in km
  }
  function processFrameA(value) {
    eucData.voltage = shortFromBytesBE(value, 2) / 100.0;
    eucData.speed = (signedShortFromBytesBE(value, 4).abs() * 3.6) / 100.0;
    eucData.tripDistance = shortFromBytesBE(value, 8) / 1000.0; //in km
    eucData.Phcurrent = signedShortFromBytesBE(value, 10) / 100.0;
    eucData.temperature = signedShortFromBytesBE(value, 12) / 340.0 + 36.53;
    eucData.hPWM = signedShortFromBytesBE(value, 14).abs() / 100.0;
  }
}

class VeteranDecoder {
  function frameBuffer(transmittedFrame) {
    for (var i = 0; i < transmittedFrame.size(); i++) {
      if (checkChar(transmittedFrame[i]) == true) {
        processFrame(frame);
      }
    }
  }

  // adapted from wheellog
  var old1 = 0;
  var old2 = 0;
  var len = 0;

  var frame as ByteArray?;
  var state = "unknown";
  function checkChar(c) {
    if (state.equals("collecting") && frame != null) {
      var size = frame.size();

      if (
        ((size == 22 || size == 30) && c.toNumber() != 0) ||
        (size == 23 && (c & 0xfe).toNumber() != 0) ||
        (size == 31 && (c & 0xfc).toNumber() != 0)
      ) {
        state = "done";
        reset();
        return false;
      }
      frame.add(c);
      if (size == len + 3) {
        state = "done";
        reset();
        return true;
      }
      // break;
    } else if (state.equals("lensearch")) {
      frame.add(c);
      len = c & 0xff;
      state = "collecting";
      old2 = old1;
      old1 = c;
      //break;
    } else {
      if (
        c.toNumber() == 92 &&
        old1.toNumber() == 90 &&
        old2.toNumber() == 220
      ) {
        frame = new [0]b;
        frame.add(220);
        frame.add(90);
        frame.add(92);
        state = "lensearch";
      } else if (c.toNumber() == 90 && old1.toNumber() == 220) {
        old2 = old1;
      } else {
        old2 = 0;
      }
      old1 = c;
    }
    return false;
  }
  function reset() {
    old1 = 0;
    old2 = 0;
    state = "unknown";
  }

  function processFrame(value) {
    eucData.voltage =
      value.decodeNumber(Lang.NUMBER_FORMAT_SINT16, {
        :offset => 4,
        :endianness => Lang.ENDIAN_BIG,
      }) / 100.0;
    eucData.speed =
      value.decodeNumber(Lang.NUMBER_FORMAT_SINT16, {
        :offset => 6,
        :endianness => Lang.ENDIAN_BIG,
      }) / 10.0;
    eucData.Phcurrent =
      value.decodeNumber(Lang.NUMBER_FORMAT_SINT16, {
        :offset => 16,
        :endianness => Lang.ENDIAN_BIG,
      }) / 10.0;
    eucData.tripDistance =
      (((value[8 + 2] & 0xff) << 24) |
        ((value[8 + 3] & 0xff) << 16) |
        ((value[8] & 0xff) << 8) |
        (value[8 + 1] & 0xff)) /
      1000.0;
    eucData.totalDistance =
      (((value[12 + 2] & 0xff) << 24) |
        ((value[12 + 3] & 0xff) << 16) |
        ((value[12] & 0xff) << 8) |
        (value[12 + 1] & 0xff)) /
      1000.0;

    //from eucWatch :
    eucData.temperature = ((value[18] << 8) | value[19]) / 100;
    // implement chargeMode/speedAlert/speedTiltback later
    eucData.version =
      value.decodeNumber(Lang.NUMBER_FORMAT_SINT16, {
        :offset => 28,
        :endianness => Lang.ENDIAN_BIG,
      }) / 1000.0;
    eucData.hPWM =
      value.decodeNumber(Lang.NUMBER_FORMAT_SINT16, {
        :offset => 34,
        :endianness => Lang.ENDIAN_BIG,
      }) / 100.0;
  }
}

class KingsongDecoder {
  var char;
  var bleDelegate;
  var queue;

  function setBleDelegate(_bleDelegate) {
    bleDelegate = _bleDelegate;
  }

  function getEmptyRequest() {
    return [
      0xaa, 0x55, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x14, 0x5a, 0x5a,
    ]b;
  }

  function processFrame(value) {
    if (value.size() >= 20) {
      var a1 = value[0] & 255;
      var a2 = value[1] & 255;
      if (a1 != 170 || a2 != 85) {
        return false;
      }
      if ((value[16] & 255) == 0xa9) {
        // Live data
        var voltage = decode2bytes(value[2], value[3]) / 100.0;
        eucData.voltage = voltage; //wd.setVoltage(voltage);

        eucData.speed = decode2bytes(value[4], value[5]) / 100.0;

        if (
          eucData.model.equals("KS-18L") &&
          eucData.KS18L_scale_toggle == true
        ) {
          eucData.totalDistance =
            (0.83 * decode4bytes(value[6], value[7], value[8], value[9])) /
            1000.0;
        } else {
          eucData.totalDistance =
            decode4bytes(value[6], value[7], value[8], value[9]) / 1000.0;
        }
        //eucData.current = decode2bytes(value[10], value[11]);
        var KScurrent = (value[11] << 8) | value[10];
        if (32767 < KScurrent) {
          KScurrent = KScurrent - 65536;
        }
        eucData.current = KScurrent / 100.0;
        eucData.temperature = decode2bytes(value[12], value[13]) / 100.0;

        if ((value[15] & 255) == 224) {
          var mMode = value[14]; // don't know what it is
        }
        return true;
      } else if ((value[16] & 255) == 0xb9) {
        // Distance/Time/Fan Data
        eucData.tripDistance =
          decode4bytes(value[2], value[3], value[4], value[5]) / 1000.0;
        eucData.temperature2 = decode2bytes(value[14], value[15]) / 100.0;
      } else if ((value[16] & 255) == 187) {
        // Name and Type data : Don't get why it's so "twisted" but OK ...
        var end;
        var i = 0;
        var advName = "";
        while (i < 14 && value[i + 2] != 0) {
          i++;
        }
        end = i + 2;
        for (i = 2; i < end; i++) {
          advName = advName + value[i].toChar().toString();
        }
        System.println(advName);
        var model = "";
        var ss = splitstr(advName, "-");
        for (i = 0; i < ss.size() - 1; i++) {
          if (i != 0) {
            model = model + "-";
          }
          model = model + ss[i];
          System.println("." + model + ".");
        }

        eucData.model = model;
      } else if ((value[16] & 255) == 0xf5) {
        //cpu load
        eucData.cpuLoad = value[14];
        eucData.hPWM = value[15];
        return false;
      }
    }
    return false;
  }

  function decode2bytes(byte1, byte2) {
    return (byte1 & 0xff) + (byte2 << 8);
  }
  function decode4bytes(byte1, byte2, byte3, byte4) {
    return (byte1 << 16) + (byte2 << 24) + byte3 + (byte4 << 8);
  }
}
