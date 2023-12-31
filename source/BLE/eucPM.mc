using Toybox.BluetoothLowEnergy as Ble;
using Toybox.System as Sys;

module eucPM {
  var EUC_SERVICE;
  var EUC_CHAR;

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

  function setGotwayOrVeteran() {
    EUC_SERVICE = Ble.longToUuid(0x0000ffe000001000l, 0x800000805f9b34fbl);
    EUC_CHAR = Ble.longToUuid(0x0000ffe100001000l, 0x800000805f9b34fbl);
    self.init();
  }

  function setManager() {
    if (
      eucData.wheelBrand == 0 ||
      eucData.wheelBrand == 1 ||
      eucData.wheelBrand == 2
    ) {
      // System.println("GW PM");
      setGotwayOrVeteran();
    }
  }
}
