import Toybox.Lang;
using Toybox.StringUtil;
using Toybox.Math;
using Toybox.System;
import Toybox.Time;

// convert string to byte, used when sending string command via BLE
function string_to_byte_array(plain_text) {
  var options = {
    :fromRepresentation => StringUtil.REPRESENTATION_STRING_PLAIN_TEXT,
    :toRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY,
    :encoding => StringUtil.CHAR_ENCODING_UTF8,
  };
  var result = StringUtil.convertEncodedString(plain_text, options);
  return result;
}

//Just a round function with formating
function valueRound(value, format) {
  if (value != null) {
    var rounded;
    rounded = Math.round(value * 100) / 100;
    return rounded.format(format);
  } else {
    return "--";
  }
}

// Get a point coord on a circle
function getXY(screenDiam, startingAngle, radius, angle, pos) {
  var x =
    screenDiam / 2 -
    radius * Math.sin(Math.toRadians(startingAngle - angle * pos));
  var y =
    screenDiam / 2 -
    radius * Math.cos(Math.toRadians(startingAngle - angle * pos));
  return [x, y];
}

function splitstr(str as Lang.String, char) {
  var stringArray;

  stringArray = new [0];

  var strlength = str.length();
  for (var i = 0; i < strlength; i++) {
    var endidx = str.find(char);
    if (endidx != null) {
      var substr = str.substring(0, endidx);
      if (substr != null) {
        stringArray.add(substr);
        var startidx = endidx + 1;
        str = str.substring(startidx, null);
      }
    } else {
      if (str.length() > 0) {
        stringArray.add(str);
        break;
      } else {
        break;
      }
    }
  }
  return stringArray;
}

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
      (((bytes[starting] & 0xff) << 24) |
        ((bytes[starting + 1] & 0xff) << 16) |
        ((bytes[starting + 2] & 0xff) << 8) |
        (bytes[starting + 3] & 0xff)) &
      0xffffffffl
    ).toNumber();
  }
  return 0;
}

function decode2bytes(byte1, byte2) {
  return (byte1 & 0xff) + (byte2 << 8);
}
function decode4bytes(byte1, byte2, byte3, byte4) {
  return (byte1 << 16) + (byte2 << 24) + byte3 + (byte4 << 8);
}
function decodeint16(byte1, byte2) {
  return (byte1 << 8) | byte2;
}

function decodeint32(byte1, byte2, byte3, byte4) {
  return (byte1 << 24) | (byte2 << 16) | (byte3 << 8) | byte4;
}
function stringToArrays(str) {
  var array = splitstr(str, ";");
  var nestedArray = new [0];
  for (var i = 0; i < array.size(); i++) {
    var temp_array = splitstr(array[i], ",");
    var points;
    var points_nb = temp_array.size();
    var limitsize = 64;
    if (points_nb > limitsize) {
      var loop_nb = points_nb / limitsize.toFloat();
      var temp_coord_array;
      //System.println("alert split required");

      for (var z = 0; z < loop_nb; z++) {
        var startindex = limitsize * z;
        if (z + 1 < loop_nb) {
          temp_coord_array = temp_array.slice(startindex, limitsize * (z + 1));
        } else {
          temp_coord_array = temp_array
            .slice(startindex, null)
            .add(temp_array.slice(0, 1)[0]); // adding first point at last pos
        }
        points = new [temp_coord_array.size()];
        for (var j = 0; j < temp_coord_array.size(); j++) {
          var coord_array = splitstr(temp_coord_array[j], "-");
          points[j] = sArray2nArray(coord_array) as Array<Number>;
        }
        nestedArray.add(points);
      }
    } else {
      points = new [temp_array.size()];
      for (var j = 0; j < temp_array.size(); j++) {
        var coord_array = splitstr(temp_array[j], "-");
        points[j] = sArray2nArray(coord_array) as Array<Number>;
      }
      nestedArray.add(points);
    }
  }
  return nestedArray;
}

function sArray2nArray(sArray) {
  // System.println(sArray);
  var nArray = new [2] as Array<Number>;
  nArray[0] = sArray[0].toNumber() + eucData.logoOffsetx;
  nArray[1] = sArray[1].toNumber() + eucData.logoOffsety;
  return nArray;
}

// varia sim
class fakeVariaTarget {
  var range = 0;
  var threat = 0;
  var threatSide = 0;
  var speed = 0;

  function assign() {
    range = random(0, 100);
    speed = random(0, 25);
    threat = 1;
    threatSide = 0;
  }
}

function fakeVaria(vehiculeNb) {
  var fakeTargetArray = [];

  for (var i = 0; i < 8; i++) {
    var target = new fakeVariaTarget();
    if (i < vehiculeNb) {
      target.assign();
    }
    fakeTargetArray.add(target);
  }
  return fakeTargetArray;
}

function variaMove(targetArray) {
  // System.println(targetArray.size());
  for (var i = 0; i < targetArray.size(); i++) {
    var remainingDist = targetArray[i].range - targetArray[i].speed / 5;
    if (remainingDist > 0) {
      targetArray[i].range = remainingDist;
    } else {
      if (i + 1 < targetArray.size() - 1) {
        targetArray[i].range = targetArray[i + 1].range;
        targetArray[i].speed = targetArray[i + 1].speed;
        targetArray[i].threat = targetArray[i + 1].threat;
      } else {
        targetArray[i].range = 0;
        targetArray[i].speed = 0;
        targetArray[i].threat = 0;
      }
    }
  }

  //targetArray.remove(new fakeVariaTarget());

  return targetArray;
}
function random(min, max) {
  return (Math.rand() % max) + 1;
}
