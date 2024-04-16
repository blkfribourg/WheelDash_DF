using Toybox.BluetoothLowEnergy as Ble;
using Toybox.System as Sys;

module eucPM {
  var EUC_SERVICE = Ble.longToUuid(0x0000ffe000001000l, 0x800000805f9b34fbl);
  var EUC_CHAR = Ble.longToUuid(0x0000ffe100001000l, 0x800000805f9b34fbl);
  var OLD_KS_ADV_SERVICE = Ble.longToUuid(
    0x0000fff000001000l,
    0x800000805f9b34fbl
  );
  var EUC_CHAR_W;
  var eucProfileDef;

  function init() {
    eucProfileDef = {
      :uuid => EUC_SERVICE,
      :characteristics => [
        {
          :uuid => EUC_CHAR,
          :descriptors => [Ble.cccdUuid()],
        },
      ],
    };
  }
  function initInmotionV2orVESC() {
    eucProfileDef = {
      // Set the Profile
      :uuid => EUC_SERVICE,
      :characteristics => [
        {
          // Define the characteristics
          :uuid => EUC_CHAR_W, // UUID of the first characteristic
          :descriptors => [Ble.cccdUuid()],
        },
        {
          // Define the characteristics
          :uuid => EUC_CHAR, // UUID of the first characteristic
          :descriptors => [Ble.cccdUuid()],
        },
      ],
    };
  }

  function registerProfiles() {
    try {
      Ble.registerProfile(eucProfileDef);
    } catch (e) {
      // Sys.println("e=" + e.getErrorMessage());
    }
  }

  function setGotwayOrVeteranOrKingsong() {
    self.init();
  }
  function setInmotionV2orVESC() {
    EUC_SERVICE = Ble.longToUuid(0x6e400001b5a3f393l, 0xe0a9e50e24dcca9el);
    EUC_CHAR = Ble.longToUuid(0x6e400003b5a3f393l, 0xe0a9e50e24dcca9el);
    EUC_CHAR_W = Ble.longToUuid(0x6e400002b5a3f393l, 0xe0a9e50e24dcca9el);

    self.initInmotionV2orVESC();
  }

  function setManager() {
    if (eucData.wheelBrand <= 3) {
      // System.println("GW PM");
      setGotwayOrVeteranOrKingsong();
    }
    if (eucData.wheelBrand >= 4) {
      setInmotionV2orVESC();
    }
  }
}
