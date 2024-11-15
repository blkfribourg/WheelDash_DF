var cfgArray;
var directionDict = {
  "z" => 40,
  "q" => 41,
  "d" => 42,
  "w" => 43,
  "c" => 44,
  "a" => 45,
  "e" => 46,
  "x" => 47,
  "r" => null,
  "f" => null,
};
function arrayToRawCmd(str_bytes) {
  return Toybox.StringUtil.convertEncodedString(str_bytes, {
    :fromRepresentation => Toybox.StringUtil.REPRESENTATION_STRING_HEX,
    :toRepresentation => Toybox.StringUtil.REPRESENTATION_BYTE_ARRAY,
  });
}
