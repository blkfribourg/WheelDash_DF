import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class GarminEUCApp extends Application.AppBase {
  private var view;
  //  private var delegate;
  private var eucBleDelegate;
  //private var queue;
  // private var EUCSettingsDict;
  // private var updateDelay = 100;
  //private var alarmsTimer;
  // private var menu;
  //private var menu2Delegate;
  //private var activityAutosave;
  // private var activityAutorecording;
  // private var activityrecordview;
  // private var debug;
  // private var actionButtonTrigger;
  // private var profileMenu;
  function initialize() {
    AppBase.initialize();

    //actionButtonTrigger = new ActionButton();
  }

  // onStart() is called on application start up
  function onStart(state as Dictionary?) as Void {
    // Sandbox zone
    //profileMenu= createMenu(["Profile1","Profile2","Profile3"],"Profile Selection");
    // end of sandbox
    setSettings();
  }

  // Return the initial view of your application here
  function getInitialView() as Array<Views or InputDelegates>? {
    //queue = new BleQueue();

    if (Toybox has :BluetoothLowEnergy) {
      eucPM.setManager();
      eucBleDelegate = new eucBLEDelegate(frameDecoder.init());
      BluetoothLowEnergy.setDelegate(eucBleDelegate);
      eucPM.registerProfiles();
    }

    view = new GarminEUCDF();
    return [view] as Array<Views or InputDelegates>;
  }

  function setSettings() {
    /*
    eucData.maxDisplayedSpeed = AppStorage.getSetting("maxSpeed");
    eucData.mainNumber = AppStorage.getSetting("mainNumber");
    eucData.topBar = AppStorage.getSetting("topBar");
    */
    eucData.wheelBrand = AppStorage.getSetting("wheelBrand");
    eucData.gothPWN = AppStorage.getSetting("begodeCF");
    eucData.currentCorrection = AppStorage.getSetting("currentCorrection");
    //eucData.maxTemperature = AppStorage.getSetting("maxTemperature");
    //eucData.updateDelay = AppStorage.getSetting("updateDelay");
    eucData.rotationSpeed = AppStorage.getSetting("rotationSpeed_PWM");
    eucData.rotationVoltage = AppStorage.getSetting("rotationVoltage_PWM");
    eucData.powerFactor = AppStorage.getSetting("powerFactor_PWM");
    eucData.voltage_scaling = AppStorage.getSetting("voltageCorrectionFactor");
    eucData.speedCorrectionFactor = AppStorage.getSetting(
      "speedCorrectionFactor"
    );
    /*
    eucData.alarmThreshold_PWM = AppStorage.getSetting("alarmThreshold_PWM");
    eucData.alarmThreshold_speed = AppStorage.getSetting(
      "alarmThreshold_speed"
    );
    eucData.alarmThreshold_temp = AppStorage.getSetting("alarmThreshold_temp");
    */

    //activityAutorecording = AppStorage.getSetting("activityRecordingOnStartup");
    //activityAutosave = AppStorage.getSetting("activitySavingOnExit");
    //debug = AppStorage.getSetting("debugMode");
    /*
    rideStats.showAverageMovingSpeedStatistic = AppStorage.getSetting(
      "averageMovingSpeedStatistic"
    );
    rideStats.showTopSpeedStatistic =
      AppStorage.getSetting("topSpeedStatistic");

    rideStats.showWatchBatteryConsumptionStatistic = AppStorage.getSetting(
      "watchBatteryConsumptionStatistic"
    );
    rideStats.showTripDistance = AppStorage.getSetting("tripDistanceStatistic");

    rideStats.showVoltage = AppStorage.getSetting("voltageStatistic");
    rideStats.showWatchBatteryStatistic = AppStorage.getSetting(
      "watchBatteryStatistic"
    );
      actionButtonTrigger.recordActivityButton = AppStorage.getSetting(
      "recordActivityButtonMap"
    );
    actionButtonTrigger.cycleLightButton = AppStorage.getSetting(
      "cycleLightButtonMap"
    );
    actionButtonTrigger.beepButton = AppStorage.getSetting("beepButtonMap");
    actionButtonTrigger.delay = AppStorage.getSetting("actionQueueDelay");
    */
  }
}

function getApp() as GarminEUCApp {
  return Application.getApp() as GarminEUCApp;
}
