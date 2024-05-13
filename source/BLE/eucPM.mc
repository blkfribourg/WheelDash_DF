using Toybox.BluetoothLowEnergy as Ble;
using Toybox.System as Sys;

module eucPM {
  var EUC_SERVICE = Ble.longToUuid(0x0000ffe000001000l, 0x800000805f9b34fbl);
  var EUC_CHAR = Ble.longToUuid(0x0000ffe100001000l, 0x800000805f9b34fbl);
  var OLD_KS_ADV_SERVICE = Ble.longToUuid(
    0x0000fff000001000l,
    0x800000805f9b34fbl
  );

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

  function registerProfiles() {
    try {
      Ble.registerProfile(eucProfileDef);
    } catch (e) {
      Sys.println("e=" + e.getErrorMessage());
    }
  }

  function setGotwayOrVeteranOrKingsong() {
    self.init();
  }

  function setManager() {
    if (
      eucData.wheelBrand == 0 ||
      eucData.wheelBrand == 1 ||
      eucData.wheelBrand == 2 ||
      eucData.wheelBrand == 3
    ) {
      // System.println("GW PM");
      setGotwayOrVeteranOrKingsong();
    }
  }
}
