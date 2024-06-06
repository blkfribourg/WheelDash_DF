module eucData {
  //var GUI = false;
  var orangeColoringThreshold = 80;
  var redColoringThreshold = 90;
  var mainNumber = 0;
  var topBar = 0;
  var maxDisplayedSpeed = 0;
  var isFirst = false;
  var profile = "";
  var logoFill = "";
  var logoEmpty = "";
  var logoOffsetx = 0;
  var logoOffsety = 0;
  var fontID = 0;
  var logoColor = 0x1f1f1f;
  var txtColor = 0xffffff;
  var txtColor_unpr = 0xff8000;
  var linesColor = 0xffffff;
  var drawLines = true;
  var wheelBrand;
  var paired = false;
  var debug = false;

  var displayNorth = false;
  var displayWind = false;
  // Calculated PWM variables :
  // PLEASE UPDATE WITH YOU OWN VALUES BEFORE USE !
  var rotationSpeed; // cutoff speed when freespin test performed
  var powerFactor; // 0.9 for better safety
  var rotationVoltage; // voltage when freespin test performed
  var speedCorrectionFactor = 1; // correct distance aswell ...
  var voltage_scaling = 1;
  var speed = 0.0;
  var correctedSpeed = 0.0;
  var voltage = 0.0;
  var lowestBatteryPercentage = 101;
  var tripDistance = 0.0;
  var Phcurrent = 0.0;
  var current = 0.0;
  var temperature = 0.0;
  var maxTemperature = 65;
  var totalDistance = 0.0;
  var PWM = 0;
  var hPWM = 0.0;
  var currentCorrection;
  var gothPWN = false;
  var battery = 0;
  // Veteran specific
  var version = 0;

  // Kingsong specific
  var KSName = "";
  var KS18L_scale_toggle = false;
  var model = "none";
  var temperature2 = 0;
  var cpuLoad = 0;

  //alarms
  var alarmThreshold_PWM = 0;
  var alarmThreshold2_PWM = 0;
  var alarmThreshold_speed = 0;
  var alarmThreshold_temp = 0;
  var vibeIntensity = 90;

  //Varia
  var variaTargetNb = 0;
  var variaTargetDist = 0;
  var variaTargetSpeed = 0;
  var timerState = -1;
  var variaCloseAlarmDistThr = 15;
  var variaFarAlarmDistThr = 50;

  var useRadar = false;

  function getBatteryPercentage() {
    if (voltage != null) {
      // using better battery formula from wheellog

      // GOTWAY ---------------------------------------------------
      if (wheelBrand == 0) {
        if (voltage > 66.8) {
          battery = 100.0;
        } else if (voltage > 54.4) {
          battery = (voltage - 53.8) / 0.13;
        } else if (voltage > 52.9) {
          battery = (voltage - 52.9) / 0.325;
        } else {
          battery = 0.0;
        }
      }
      // ----------------------------------------------------------
      // VETERAN ------------------------------------------------
      if (wheelBrand == 1) {
        if (version < 4) {
          // models before Patton
          if (voltage > 100.2) {
            battery = 100.0;
          } else if (voltage > 81.6) {
            battery = (voltage - 80.7) / 0.195;
          } else if (voltage > 79.35) {
            battery = (voltage - 79.35) / 0.4875;
          } else {
            battery = 0.0;
          }
        }
        if (version > 4 && version < 5) {
          // Patton
          if (voltage > 125.25) {
            battery = 100.0;
          } else if (voltage > 102.0) {
            battery = (voltage - 99.75) / 0.255;
          } else if (voltage > 96.0) {
            battery = (voltage - 96.0) / 0.675;
          } else {
            battery = 0.0;
          }
        }
        if (version > 5 && version < 6) {
          // Lynx
          if (voltage > 150.3) {
            battery = 100.0;
          } else if (voltage > 122.4) {
            battery = (voltage - 119.7) / 0.306;
          } else if (voltage > 115.2) {
            battery = (voltage - 115.2) / 0.81;
          } else {
            battery = 0.0;
          }
        }
      }
      //-----------------------------------------------------------
      //Kingsong --------------------------------------------------

      if (wheelBrand == 2) {
        var KSwheels84v = [
          "KS-18L",
          "KS-16X",
          "KS-16XF",
          "RW",
          "KS-18LH",
          "KS-18LY",
          "KS-S18",
        ];
        var KSwheels100v = ["KS-S19"];
        var KSwheels126v = ["KS-S20", "KS-S22"];

        if (KSwheels84v.indexOf(model) != -1) {
          if (voltage > 83.5) {
            battery = 100.0;
          } else if (voltage > 68.0) {
            battery = (voltage - 66.5) / 0.17;
          } else if (voltage > 64.0) {
            battery = (voltage - 64.0) / 0.45;
          } else {
            battery = 0.0;
          }
        } else if (KSwheels100v.indexOf(model) != -1) {
          if (voltage > 100.2) {
            battery = 100.0;
          } else if (voltage > 81.6) {
            battery = (voltage - 79.8) / 0.204;
          } else if (voltage > 76.8) {
            battery = (voltage - 76.8) / 0.54;
          } else {
            battery = 0.0;
          }
        } else if (KSwheels126v.indexOf(model) != -1) {
          if (voltage > 125.25) {
            battery = 100.0;
          } else if (voltage > 102.0) {
            battery = (voltage - 99.75) / 0.255;
          } else if (voltage > 96.0) {
            battery = (voltage - 96.0) / 0.675;
          } else {
            battery = 0.0;
          }
        } else {
          // unknown model
          battery = 0.0;
        }
      }
    } else {
      battery = 0.0;
    }
    // ----------------------------------------------------------
    return battery;
  }

  function getPWM() {
    if (eucData.voltage != null) {
      //Quick&dirty fix for now, need to rewrite this:
      if (wheelBrand == 1 || wheelBrand == 2 || gothPWN == true) {
        return hPWM;
      } else {
        if (eucData.voltage != 0) {
          var CalculatedPWM =
            eucData.speed.toFloat() /
            ((rotationSpeed / rotationVoltage) *
              eucData.voltage.toFloat() *
              eucData.voltage_scaling *
              powerFactor);
          return CalculatedPWM * 100;
        } else {
          return 0.0;
        }
      }
    } else {
      return 0.0;
    }
  }
  function getCurrent() {
    var currentCurrent = 0;
    if (wheelBrand == 0 || wheelBrand == 1) {
      if (currentCorrection == 0) {
        currentCurrent = (getPWM() / 100) * eucData.Phcurrent;
      }
      if (currentCorrection == 1) {
        currentCurrent = (getPWM() / 100) * -eucData.Phcurrent;
      }
      if (currentCorrection == 2) {
        currentCurrent = (getPWM() / 100) * eucData.Phcurrent.abs();
      }
    } else {
      currentCurrent = current;
    }

    return currentCurrent;
  }
  function getCorrectedSpeed() {
    return speed * speedCorrectionFactor.toFloat();
  }

  function getVoltage() {
    if (voltage != null) {
      if (wheelBrand == 0) {
        // gotway
        return voltage * voltage_scaling;
      } else {
        return voltage;
      }
    } else {
      return voltage;
    }
  }
}
