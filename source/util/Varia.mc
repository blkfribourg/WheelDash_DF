using Toybox.Attention;
using Toybox.System;
import Toybox.Time;
module Varia {
  var prevCount = 0;
  var triggerVariaAlarm = false;
  var nextVariaTrigger;
  var triggerDelay = new Time.Duration(1);
  // Debounce for the "all clear" tone. processTarget() is driven by the EUC's
  // BLE notification rate (can be tens of Hz), far faster than the Varia
  // radar's own broadcast rate (~4Hz) or the reload rate of getRadarInfo().
  // Without a cooldown here, a single momentarily-empty target-count read
  // between two real detections (radar read racing the next broadcast) makes
  // soundClear() fire every time it happens, sounding like the alert is
  // spamming -- unlike soundAlert()'s tones, this one had no gate at all.
  var nextVariaClearTrigger;
  var clearTriggerDelay = new Time.Duration(2);

  function processTarget(_target) {
    if (_target != null) {
      if (_target.size() != 0) {
        if (_target[0].threat != 0) {
          eucData.variaTargetDist = _target[0].range;
          eucData.variaTargetSpeed = _target[0].speed;
          soundAlert(_target[0].range);
        }

        var veh_count = 0;
        for (var i = 0; i < _target.size(); i++) {
          if (_target[i].threat != 0) {
            veh_count = veh_count + 1;
          }
        }

        eucData.variaTargetNb = veh_count;
        if (prevCount > veh_count && veh_count == 0) {
          //no more cars
          //System.println("no cars");
          var clearNow = Time.now();
          if (
            nextVariaClearTrigger == null ||
            nextVariaClearTrigger.compare(clearNow as Time.Moment) < 0
          ) {
            soundClear();
            nextVariaClearTrigger = Time.now().add(
              clearTriggerDelay
            );
          }
          eucData.variaTargetDist = 0;
          eucData.variaTargetSpeed = 0;
        }
        if (prevCount > veh_count) {
          eucData.totalVehCount =
            eucData.totalVehCount + (prevCount - veh_count);
        }
        prevCount = veh_count;
      }
    }
  }

  function soundAlert(distance) {
    triggerVariaAlarm = true;
    var variaNow = Time.now();

    if (
      nextVariaTrigger != null &&
      nextVariaTrigger.compare(variaNow as Time.Moment) >= 0
    ) {
      triggerVariaAlarm = false;
    }
    if (
      eucData.variaFarAlarmDistThr != 0 &&
      distance < eucData.variaFarAlarmDistThr &&
      distance > eucData.variaCloseAlarmDistThr
    ) {
      // far car
      if (Attention has :playTone && triggerVariaAlarm == true) {
        //   System.println("triggerFar");
        Attention.playTone(Attention.TONE_DISTANCE_ALERT);
        nextVariaTrigger = Time.now().add(triggerDelay);
      }
    }
    if (
      eucData.variaCloseAlarmDistThr != 0 &&
      distance <= eucData.variaCloseAlarmDistThr
    ) {
      // close car
      if (Attention has :playTone && triggerVariaAlarm == true) {
        //  System.println("triggerclose");
        Attention.playTone(Attention.TONE_ALARM);
        nextVariaTrigger = Time.now().add(triggerDelay);
      }
    }
  }

  function soundClear() {
    if (Attention has :playTone) {
      Attention.playTone(Attention.TONE_SUCCESS);
    }
  }
}
//far car : TONE_DISTANCE_ALERT
//close car : TONE_ALARM
//no more cars: TONE_SUCCESS
//speed : TONE_CANARY
