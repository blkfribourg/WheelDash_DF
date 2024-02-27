using Toybox.Attention;
module Varia {
  function processTarget(_target) {
    var closestTargetDist = 200; // 200 meters should be enough to exceding varia max distance (reported max is 140m)
    var closestTargetId = -1;
    for (var i = 0; i < _target.size(); i++) {
      if (_target[i].range < closestTargetDist) {
        closestTargetDist = _target[i].range;
        closestTargetId = i;
      }
    }
    if (closestTargetId != -1) {
      // vehicule was detected
      soundAlert(closestTargetDist);
    }
  }

  function soundAlert(distance) {
    // WIP from sandbox
    var minTonePitch = 500;
    var maxTonePitch = 2000;
    var maxDetectableDist = 140;
    var pitchIncrement = (maxTonePitch - minTonePitch) / maxDetectableDist;
    var soundFreq = maxTonePitch - pitchIncrement * distance;
    if (soundFreq > 0) {
      //should be
      var toneProfile = [new Attention.ToneProfile(soundFreq, 200)];

      if (Attention has :ToneProfile) {
        Attention.playTone({ :toneProfile => toneProfile });
      }
    }
  }
}
