import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class GarminEUCApp extends Application.AppBase {
  private var view;
  //  private var delegate;
  private var eucBleDelegate;
  private var currentProfile;

  function initialize() {
    AppBase.initialize();
    currentProfile = AppStorage.getSetting("profile");
    //actionButtonTrigger = new ActionButton();
  }

  // onStart() is called on application start up
  function onStart(state as Dictionary?) as Void {
    // Sandbox zone
    //profileMenu= createMenu(["Profile1","Profile2","Profile3"],"Profile Selection");
    // end of sandbox
    setSettings(currentProfile);
    //init alarms
    EUCAlarms.alarmsInit();
  }

  // Return the initial view of your application here
  function getInitialView() {
    //Connect IQ7
    // function getInitialView() as Array<Views or InputDelegates>? {
    //queue = new BleQueue();

    if (Toybox has :BluetoothLowEnergy) {
      eucPM.setManager();
      eucBleDelegate = new eucBLEDelegate(frameDecoder.init());
      BluetoothLowEnergy.setDelegate(eucBleDelegate);
      eucPM.registerProfiles();
    }

    view = new GarminEUCDF();
    return [view]; //Connect IQ7
    // return [view] as Array<Views or InputDelegates>?;
  }

  function setSettings(profile) {
    eucData.useRadar = AppStorage.getSetting("useRadar");
    eucData.variaCloseAlarmDistThr = AppStorage.getSetting(
      "variaCloseAlarmDistThr"
    );
    eucData.variaFarAlarmDistThr = AppStorage.getSetting(
      "variaFarAlarmDistThr"
    );
    eucData.displayNorth = AppStorage.getSetting("displayNorth");
    eucData.displayWind = AppStorage.getSetting("displayWind");
    eucData.vibeIntensity = AppStorage.getSetting("vibeIntensity");
    eucData.profile = AppStorage.getSetting("profile");
    eucData.debug = AppStorage.getSetting("debugView");
    eucData.logoFill = AppStorage.getSetting("logoFill");
    eucData.logoEmpty = AppStorage.getSetting("logoEmpty");
    eucData.logoColor = AppStorage.getSetting("logoColor").toNumberWithBase(16);
    eucData.linesColor =
      AppStorage.getSetting("linesColor").toNumberWithBase(16);
    eucData.txtColor = AppStorage.getSetting("txtColor").toNumberWithBase(16);
    eucData.txtColor_unpr =
      AppStorage.getSetting("txtColor_unpr").toNumberWithBase(16);
    eucData.fontID = AppStorage.getSetting("font");
    eucData.logoOffsetx = AppStorage.getSetting("logoOffsetx");
    eucData.logoOffsety = AppStorage.getSetting("logoOffsety");
    eucData.drawLines = AppStorage.getSetting("drawLines");

    if (eucData.profile == 1) {
      eucData.wheelBrand = AppStorage.getSetting("wheelBrand_p1");
      eucData.gothPWN = AppStorage.getSetting("begodeCF_p1");
      eucData.currentCorrection = AppStorage.getSetting("currentCorrection_p1");
      eucData.rotationSpeed = AppStorage.getSetting("rotationSpeed_PWM_p1");
      eucData.rotationVoltage = AppStorage.getSetting("rotationVoltage_PWM_p1");
      eucData.powerFactor = AppStorage.getSetting("powerFactor_PWM_p1");
      eucData.voltage_scaling = AppStorage.getSetting(
        "voltageCorrectionFactor_p1"
      );
      eucData.speedCorrectionFactor = AppStorage.getSetting(
        "speedCorrectionFactor_p1"
      );
      eucData.alarmThreshold_PWM = AppStorage.getSetting(
        "alarmThreshold_PWM_p1"
      );
      eucData.alarmThreshold2_PWM = AppStorage.getSetting(
        "alarmThreshold2_PWM_p1"
      );
      eucData.alarmThreshold_speed = AppStorage.getSetting(
        "alarmThreshold_speed_p1"
      );
      eucData.alarmThreshold_temp = AppStorage.getSetting(
        "alarmThreshold_temp_p1"
      );
      Storage.setValue("lastProfileIdx", profile);
    } else if (eucData.profile == 2) {
      eucData.wheelBrand = AppStorage.getSetting("wheelBrand_p2");
      eucData.gothPWN = AppStorage.getSetting("begodeCF_p2");
      eucData.currentCorrection = AppStorage.getSetting("currentCorrection_p2");
      eucData.rotationSpeed = AppStorage.getSetting("rotationSpeed_PWM_p2");
      eucData.rotationVoltage = AppStorage.getSetting("rotationVoltage_PWM_p2");
      eucData.powerFactor = AppStorage.getSetting("powerFactor_PWM_p2");
      eucData.voltage_scaling = AppStorage.getSetting(
        "voltageCorrectionFactor_p2"
      );
      eucData.speedCorrectionFactor = AppStorage.getSetting(
        "speedCorrectionFactor_p2"
      );
      eucData.alarmThreshold_PWM = AppStorage.getSetting(
        "alarmThreshold_PWM_p2"
      );
      eucData.alarmThreshold2_PWM = AppStorage.getSetting(
        "alarmThreshold2_PWM_p2"
      );
      eucData.alarmThreshold_speed = AppStorage.getSetting(
        "alarmThreshold_speed_p2"
      );
      eucData.alarmThreshold_temp = AppStorage.getSetting(
        "alarmThreshold_temp_p2"
      );
    } else if (eucData.profile == 3) {
      eucData.wheelBrand = AppStorage.getSetting("wheelBrand_p3");
      eucData.gothPWN = AppStorage.getSetting("begodeCF_p3");
      eucData.currentCorrection = AppStorage.getSetting("currentCorrection_p3");
      eucData.rotationSpeed = AppStorage.getSetting("rotationSpeed_PWM_p3");
      eucData.rotationVoltage = AppStorage.getSetting("rotationVoltage_PWM_p3");
      eucData.powerFactor = AppStorage.getSetting("powerFactor_PWM_p3");
      eucData.voltage_scaling = AppStorage.getSetting(
        "voltageCorrectionFactor_p3"
      );
      eucData.speedCorrectionFactor = AppStorage.getSetting(
        "speedCorrectionFactor_p3"
      );
      eucData.alarmThreshold_PWM = AppStorage.getSetting(
        "alarmThreshold_PWM_p3"
      );
      eucData.alarmThreshold2_PWM = AppStorage.getSetting(
        "alarmThreshold2_PWM_p3"
      );
      eucData.alarmThreshold_speed = AppStorage.getSetting(
        "alarmThreshold_speed_p3"
      );
      eucData.alarmThreshold_temp = AppStorage.getSetting(
        "alarmThreshold_temp_p3"
      );
    } else {
      //if profile variable locally stored => get last setting + call fct again
      if (Storage.getValue("lastProfileIdx") != null) {
        setSettings(Storage.getValue("lastProfileIdx"));
      } else {
        setSettings(1);
      }
    }
  }
}

function getApp() as GarminEUCApp {
  return Application.getApp() as GarminEUCApp;
}
