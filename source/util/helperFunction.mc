import Toybox.Lang;
using Toybox.StringUtil;
using Toybox.Math;
using Toybox.System;

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
  var rounded;
  rounded = Math.round(value * 100) / 100;
  return rounded.format(format);
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
      ((bytes[starting] & 0xff) << 24) |
      ((bytes[starting + 1] & 0xff) << 16) |
      ((bytes[starting + 2] & 0xff) << 8) |
      (bytes[starting + 3] & 0xff)
    );
  }
  return 0;
}

function decode2bytes(byte1, byte2) {
  return (byte1 & 0xff) + (byte2 << 8);
}
function decode4bytes(byte1, byte2, byte3, byte4) {
  return (byte1 << 16) + (byte2 << 24) + byte3 + (byte4 << 8);
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
      System.println("alert split required");

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
