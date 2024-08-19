import Toybox.Attention;
import Toybox.Lang;
import Toybox.Time;
using Toybox.System;

module EUCAlarms {
  var alarmDelay = 0;
  var alarmType = "none";
  var PWMAlarm = false;
  var speedAlarm = false;
  var tempAlarm = false;
  var nextTrigger as Moment?;
  var triggerAlarm = false;
  var displayingAlert = false;
  var PWM1_thr = 0;
  var PWM2_thr = 0;
  var vibeKilled = true;
  var toneKilled = true;
  var textAlert = "";
  var PWMVibe, PWMDangerVibe, speedVibe, tempVibe, killVibe;
  var PWMTone, PWMDangerTone, speedTone, tempTone, killTone;

  function alarmsInit() {
    initVibes(eucData.vibeIntensity);
    initTones();
    if (eucData.alarmThreshold_PWM != 0 && eucData.alarmThreshold2_PWM != 0) {
      if (eucData.alarmThreshold_PWM < eucData.alarmThreshold2_PWM) {
        PWM1_thr = eucData.alarmThreshold_PWM;
        PWM2_thr = eucData.alarmThreshold2_PWM;
      } else {
        PWM2_thr = eucData.alarmThreshold_PWM;
        PWM1_thr = eucData.alarmThreshold2_PWM;
      }
    }
    if (eucData.alarmThreshold_PWM != 0 && eucData.alarmThreshold2_PWM == 0) {
      PWM1_thr = eucData.alarmThreshold_PWM;
      PWM2_thr = 0;
    }
    if (eucData.alarmThreshold_PWM == 0 && eucData.alarmThreshold2_PWM != 0) {
      PWM1_thr = eucData.alarmThreshold2_PWM;
      PWM2_thr = 0;
    }
  }
  function initVibes(intensity) {
    if (Attention has :vibrate) {
      PWMVibe = [
        new Attention.VibeProfile(intensity, 250),
        new Attention.VibeProfile(0, 250),
        new Attention.VibeProfile(intensity, 250),
        new Attention.VibeProfile(0, 250),
      ];
      PWMDangerVibe = [
        new Attention.VibeProfile(intensity, 125),
        new Attention.VibeProfile(0, 125),
        new Attention.VibeProfile(intensity, 125),
        new Attention.VibeProfile(0, 125),
        new Attention.VibeProfile(intensity, 125),
        new Attention.VibeProfile(0, 125),
        new Attention.VibeProfile(intensity, 125),
        new Attention.VibeProfile(0, 125),
      ];
      speedVibe = [
        new Attention.VibeProfile(intensity, 350),
        new Attention.VibeProfile(0, 150),
        new Attention.VibeProfile(intensity, 100),
        new Attention.VibeProfile(0, 150),
        new Attention.VibeProfile(intensity, 100),
        new Attention.VibeProfile(0, 150),
      ];
      tempVibe = [
        new Attention.VibeProfile(intensity, 500),
        new Attention.VibeProfile(0, 200),
        new Attention.VibeProfile(intensity, 100),
        new Attention.VibeProfile(0, 200),
      ];
      killVibe = [new Attention.VibeProfile(0, 1)];
    }
  }

  function initTones() {
    if (Attention has :ToneProfile) {
      if (eucData.motorbikeHeadset == true) {
        PWMTone = Attention.TONE_INTERVAL_ALERT;

        PWMDangerTone = Attention.TONE_TIME_ALERT;

        speedTone = Attention.TONE_CANARY;

        tempTone = Attention.TONE_ALERT_HI;
      } else {
        PWMTone = [
          new Attention.ToneProfile(435, 250),
          new Attention.ToneProfile(0, 250),
          new Attention.ToneProfile(435, 250),
          new Attention.ToneProfile(0, 250),
        ];
        PWMDangerTone = [
          new Attention.ToneProfile(535, 125),
          new Attention.ToneProfile(0, 125),
          new Attention.ToneProfile(535, 125),
          new Attention.ToneProfile(0, 125),
          new Attention.ToneProfile(535, 125),
          new Attention.ToneProfile(0, 125),
          new Attention.ToneProfile(535, 125),
          new Attention.ToneProfile(0, 125),
        ];
        speedTone = [
          new Attention.ToneProfile(420, 350),
          new Attention.ToneProfile(0, 150),
          new Attention.ToneProfile(516, 100),
          new Attention.ToneProfile(0, 150),
          new Attention.ToneProfile(420, 100),
          new Attention.ToneProfile(0, 150),
        ];
        tempTone = [
          new Attention.ToneProfile(435, 500),
          new Attention.ToneProfile(0, 200),
          new Attention.ToneProfile(488, 100),
          new Attention.ToneProfile(0, 200),
        ];
        killTone = [new Attention.ToneProfile(10000, 1)];
      }
    }
  }

  function setAlarmType() {
    if (PWMAlarm == true) {
      textAlert = "!! PWM Alarm !!";
      displayingAlert = true;
    } else {
      if (tempAlarm == true) {
        textAlert = "!! Temperature Alarm !!";
        displayingAlert = true;
      } else if (speedAlarm == true) {
        textAlert = "!! Speed Alarm !!";
        displayingAlert = true;
      }
    }

    if (PWMAlarm == false && tempAlarm == false && speedAlarm == false) {
      displayingAlert = false;
      if (
        killVibe != null &&
        eucData.vibeIntensity != 0 &&
        triggerAlarm == false &&
        vibeKilled == false
      ) {
        Attention.vibrate(killVibe);
        vibeKilled = true;
      }
      if (killTone != null && triggerAlarm == false && toneKilled == false) {
        playSound(killTone);
        toneKilled = true;
      }
    }
  }
  function checkAlarms() {
    // System.println("alarmCheck");
    triggerAlarm = true;
    var now = new Time.Moment(Time.now().value());

    if (nextTrigger != null && nextTrigger.compare(now) >= 0) {
      triggerAlarm = false;
    }

    if (PWM1_thr != 0) {
      if (PWM2_thr != 0) {
        if (
          eucData.PWM > PWM1_thr &&
          eucData.PWM < PWM2_thr &&
          triggerAlarm == true
        ) {
          nextTrigger = new Time.Moment(Time.now().value());
          nextTrigger.add(new Time.Duration(1));
          if (PWMVibe != null && eucData.vibeIntensity != 0) {
            Attention.vibrate(PWMVibe);
            vibeKilled = false;
          }
          if (PWMTone != null) {
            playSound(PWMTone);
            toneKilled = false;
          }
          PWMAlarm = true;
        }
        if (eucData.PWM > PWM2_thr && triggerAlarm == true && PWM2_thr != 0) {
          if (PWMDangerVibe != null && eucData.vibeIntensity != 0) {
            Attention.vibrate(PWMDangerVibe);
            vibeKilled = false;
          }
          if (PWMDangerTone != null) {
            playSound(PWMDangerTone);
            toneKilled = false;
          }
          nextTrigger = new Time.Moment(Time.now().value());
          nextTrigger.add(new Time.Duration(1));
          PWMAlarm = true;
        }
      } else {
        if (eucData.PWM > PWM1_thr && triggerAlarm == true) {
          nextTrigger = new Time.Moment(Time.now().value());
          nextTrigger.add(new Time.Duration(1));
          if (PWMVibe != null && eucData.vibeIntensity != 0) {
            Attention.vibrate(PWMVibe);
            vibeKilled = false;
          }
          if (PWMTone != null) {
            playSound(PWMTone);
            toneKilled = false;
          }
          PWMAlarm = true;
        }
      }
      if (eucData.PWM < PWM1_thr) {
        PWMAlarm = false;
      }
    }
    //Temperature alarm
    if (eucData.alarmThreshold_temp != 0) {
      if (
        eucData.temperature > eucData.alarmThreshold_temp &&
        triggerAlarm == true &&
        PWMAlarm == false
      ) {
        // PWM alarm have priority over temperature alarm
        nextTrigger = new Time.Moment(Time.now().value());
        nextTrigger.add(new Time.Duration(1));
        if (tempVibe != null && eucData.vibeIntensity != 0) {
          Attention.vibrate(tempVibe);
          vibeKilled = false;
        }
        if (tempTone != null) {
          playSound(tempTone);
          toneKilled = false;
        }
        tempAlarm = true;
      }
      if (eucData.temperature < eucData.alarmThreshold_temp) {
        tempAlarm = false;
      }
    }
    //Speed alarm
    if (eucData.alarmThreshold_speed != 0) {
      //   System.println("speedCheck");
      //   System.println(eucData.correctedSpeed);
      //   System.println(PWMAlarm);
      //   System.println(tempAlarm);
      if (
        eucData.correctedSpeed > eucData.alarmThreshold_speed &&
        triggerAlarm == true &&
        PWMAlarm == false &&
        tempAlarm == false
      ) {
        nextTrigger = new Time.Moment(Time.now().value());
        nextTrigger.add(new Time.Duration(1));

        // PWM alarm and temperature alarm have priority over speed alarm
        if (speedVibe != null && eucData.vibeIntensity != 0) {
          Attention.vibrate(speedVibe);
          vibeKilled = false;
        }
        if (speedTone != null) {
          playSound(speedTone);
          toneKilled = false;
        }
        speedAlarm = true;
      }
      if (eucData.correctedSpeed < eucData.alarmThreshold_speed) {
        speedAlarm = false;
      }
    }
    setAlarmType();
  }

  function playSound(tone) {
    if (tone instanceof Lang.Number) {
      Attention.playTone(tone as Attention.Tone);
    }
    if (tone instanceof Lang.Array) {
      Attention.playTone({ :toneProfile => tone as Lang.Array });
    }
  }
}
