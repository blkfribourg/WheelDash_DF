// Maps a navigation turnId (single-char code from the activity's course/
// navigation data, see GarminEUCDF.mc's turnId handling) to the Engo
// glasses' built-in turn-arrow icon ID, sent over BLE to display on the
// HUD. "r"/"f" map to null intentionally -- no matching icon on the glasses.
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
