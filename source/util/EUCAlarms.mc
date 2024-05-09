using Toybox.WatchUi;
using Toybox.Attention;
using Toybox.System;
module EUCAlarms {
  var PWMAlert = false;
  var tempAlert = false;
  var speedAlert = false;
  var displayingAlert = false;
  var displayAlertTimer = 1;
  var textAlert = "";
  function checkAlarms() {
    if (WatchUi.DataField has :showAlert) {
      if (
        eucData.getPWM() > eucData.alarmThreshold_PWM &&
        eucData.alarmThreshold_PWM != 0
      ) {
        PWMAlert = true;
      } else {
        PWMAlert = false;
      }
      if (
        eucData.getTemperature() > eucData.alarmThreshold_temp &&
        eucData.alarmThreshold_temp != 0
      ) {
        tempAlert = true;
      } else {
        tempAlert = false;
      }
      if (
        eucData.getCorrectedSpeed() > eucData.alarmThreshold_speed &&
        eucData.alarmThreshold_speed != 0
      ) {
        speedAlert = true;
      } else {
        speedAlert = false;
      }
      if (PWMAlert == true) {
        textAlert = "!! PWM Alarm !!";
      } else {
        if (tempAlert == true) {
          textAlert = "!! Temperature Alarm !!";
        } else if (speedAlert == true) {
          textAlert = "!! Speed Alarm !!";
        }
      }
      if (!PWMAlert && !tempAlert && !speedAlert) {
        displayingAlert = false;
        displayAlertTimer = 2;
      } else {
        displayingAlert = true;
        System.println(displayAlertTimer);
        if (displayAlertTimer <= 0) {
          displayAlertTimer = 2;
        } else {
          vibrate();
        }
      }
    }
  }
  function vibrate() {
    if (Attention has :vibrate) {
      Attention.vibrate([
        new Attention.VibeProfile(90, 250),
        new Attention.VibeProfile(0, 250),
        new Attention.VibeProfile(90, 250),
        new Attention.VibeProfile(0, 250),
      ]);
    }
    if (Attention has :ToneProfile) {
      var toneProfile = [
        new Attention.ToneProfile(420, 250),
        new Attention.ToneProfile(516, 250),
        new Attention.ToneProfile(425, 250),
        new Attention.ToneProfile(0, 250),
      ];
      Attention.playTone({ :toneProfile => toneProfile });
    }
  }
}
