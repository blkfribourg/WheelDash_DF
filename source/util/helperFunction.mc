import Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.StringUtil;
using Toybox.Math;

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

function encodeint16(val) {
  return [(val >> 8) & 0xff, val & 0xff]b;
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

/*
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
*/
// engo related fct

function getWriteCmd(text, x, y, r, f, c) {
  var hexText = getHexText(text);

  var cmd = [0xff, 0x37, 0x00, 0x0d + hexText.size()]b;
  cmd.addAll(encodeint16(x));
  cmd.addAll(encodeint16(y)); // to finish, add X int16, Y int8
  cmd.add(r);
  cmd.add(f);
  cmd.add(c);
  cmd.addAll(hexText);
  cmd.add(0x00);
  cmd.add(0xaa);
  return cmd;
}

function getPageCmd(payload, pageId) {
  var cmd = [0xff, 0x86, 0x00, payload.size() + 6, pageId]b;
  cmd.addAll(payload);
  cmd.add(0xaa);
  return cmd;
}

function getClearRectCmd(x0, y0, x1, y1, int) {
  var cmd = [0xff, 0x30, 0x00, 6, int]b;
  cmd.add(0xaa);
  cmd.addAll([0xff, 0x34, 0x00, 13]b);
  cmd.addAll(encodeint16(x0));
  cmd.addAll(encodeint16(y0));
  cmd.addAll(encodeint16(x1));
  cmd.addAll(encodeint16(y1));
  cmd.add(0xaa);
  return cmd;
}

function getImgCmd(imgId, xPos, yPos) {
  var cmd = [0xff, 0x42, 0x00, 10, imgId]b;
  cmd.addAll(encodeint16(xPos));
  cmd.addAll(encodeint16(yPos));
  cmd.add(0xaa);
  return cmd;
}

function getHexText(text) {
  var hexText = Toybox.StringUtil.convertEncodedString(text, {
    :fromRepresentation => Toybox.StringUtil.REPRESENTATION_STRING_PLAIN_TEXT,
    :toRepresentation => Toybox.StringUtil.REPRESENTATION_BYTE_ARRAY,
  });
  var textLength = text.length();
  if (textLength < 5) {
    var leftPadding = []b;
    while (leftPadding.size() < 5 - hexText.size()) {
      leftPadding.add(0x20);
    }
    hexText = leftPadding.addAll(hexText);
  }
  hexText.add(0x20); //right padding 2 char for proper clearing
  return hexText;
}

function pagePayload(textArray) {
  var payload = []b;
  for (var i = 0; i < textArray.size(); i++) {
    payload.addAll(textArray[i]);
    payload.add(0x00);
  }
  //System.println("payload: " + payload);
  return payload;
}

function getJson(symbol) {
  return WatchUi.loadResource(Rez.JsonData[symbol]);
}

function multiline(wholeString) {
  var firstLine = "";
  var secLine = "";
  if (wholeString.length() > 20) {
    var commaIdx = wholeString.find(",");
    if (
      commaIdx != null &&
      commaIdx > 5 &&
      wholeString.substring(0, commaIdx).length() <= 20
    ) {
      firstLine = wholeString.substring(0, commaIdx);
      secLine = wholeString.substring(commaIdx + 1, null);
    } else {
      if (wholeString.length() > 20) {
        var str = wholeString;
        var idx = 0;
        var local_idx = 0;
        while (str.find(" ") != null) {
          local_idx = str.find(" ");
          if (idx + local_idx >= 20) {
            break;
          }
          str = str.substring(local_idx + 1, null);

          if (local_idx != null) {
            idx = idx + local_idx + 1;
          }
          //  System.println(idx);
        }
        var newfirstLine;
        if (idx == 0) {
          newfirstLine = wholeString;
        } else {
          newfirstLine = wholeString.substring(0, idx);
        }

        if (newfirstLine.length() <= 20) {
          firstLine = newfirstLine;
          secLine = wholeString.substring(idx, null);
        } else {
          firstLine = wholeString.substring(0, 20);
          secLine = wholeString.substring(20, null);
        }
      }
    }
  } else {
    firstLine = wholeString;
  }
  //trim space:
  firstLine = trimSpace(firstLine);
  secLine = trimSpace(secLine);
  return [firstLine, secLine];
}

function trimSpace(str) {
  while (str.find(" ") == 0) {
    str = str.substring(1, null);
  }
  //System.println(str.substring(str.length() - 1, null));
  while (str.substring(str.length() - 1, null).equals(" ")) {
    str = str.substring(0, -1);
  }
  return str;
}

function concatCmd(cmds) {
  var cmd = []b;
  for (var i = 0; i < cmds.size(); i++) {
    cmd.addAll(cmds[i]);
  }
  return cmd;
}
