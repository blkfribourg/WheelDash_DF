using Toybox.Attention;
using Toybox.System;
import Toybox.Time;
module Varia {
  var prevCount = 0;
  var triggerVariaAlarm = false;
  var nextVariaTrigger;
  var triggerDelay;
  function processTarget(_target) {
    if (_target != null) {
      if (_target.size != 0) {
        if (_target[0].threat != 0) {
          if (_target[0].threat == 1) {
            triggerDelay = new Time.Duration(1);
          }
          if (_target[0].threat == 2) {
            triggerDelay = (new Time.Duration(1)).divide(2);
          }
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
          soundClear();
          eucData.variaTargetDist = 0;
          eucData.variaTargetSpeed = 0;
        }
        prevCount = veh_count;
      }
    }
  }

  function soundAlert(distance) {
    triggerVariaAlarm = true;
    var variaNow = new Time.Moment(Time.now().value());

    if (nextVariaTrigger != null && nextVariaTrigger.compare(variaNow) >= 0) {
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
        nextVariaTrigger = new Time.Moment(Time.now().value());
        nextVariaTrigger.add(triggerDelay);
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
        nextVariaTrigger = new Time.Moment(Time.now().value());
        nextVariaTrigger.add(triggerDelay);
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
