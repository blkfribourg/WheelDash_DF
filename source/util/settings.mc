import Toybox.Lang;
using Toybox.Application.Properties;
using Toybox.System;
function colorFromProperty(key as String, fallback as Number) as Number {
  var raw = Properties.getValue(key);
  if (raw == null) {
    return fallback;
  }
  return raw.toNumberWithBase(16);
}

function setSettings(profile as Number) {
  if (eucData.debug) {
    System.println(profile);
  }
  eucData.fieldIDs = [
    Properties.getValue("field1"),
    Properties.getValue("field2"),
    Properties.getValue("field3"),
    Properties.getValue("field4"),
    Properties.getValue("field5"),
    Properties.getValue("field6"),
    Properties.getValue("field7"),
    Properties.getValue("field8"),
  ];
  eucData.fieldNB = Properties.getValue("fieldNB");
  eucData.useEngo = Properties.getValue("useEngo");
  eucData.engoTouch = Properties.getValue("engoTouch");

  eucData.useRadar = Properties.getValue("useRadar");
  eucData.convertToFahrenheit = Properties.getValue("convertToFahrenheit");
  eucData.motorbikeHeadset = Properties.getValue("motorbikeHeadset");
  eucData.variaCloseAlarmDistThr = Properties.getValue(
    "variaCloseAlarmDistThr"
  );
  eucData.variaFarAlarmDistThr = Properties.getValue("variaFarAlarmDistThr");
  eucData.displayNorth = Properties.getValue("displayNorth");
  eucData.displayWind = Properties.getValue("displayWind");
  eucData.vibeIntensity = Properties.getValue("vibeIntensity");

  eucData.debug = Properties.getValue("debugView");
  eucData.logoFill = Properties.getValue("logoFill");
  eucData.logoEmpty = Properties.getValue("logoEmpty");
  eucData.logoColor = colorFromProperty("logoColor", eucData.logoColor);
  eucData.linesColor = colorFromProperty("linesColor", eucData.linesColor);
  eucData.txtColor = colorFromProperty("txtColor", eucData.txtColor);
  eucData.txtColor_unpr = colorFromProperty(
    "txtColor_unpr",
    eucData.txtColor_unpr
  );
  eucData.fontID = Properties.getValue("font");
  eucData.logoOffsetx = Properties.getValue("logoOffsetx");
  eucData.logoOffsety = Properties.getValue("logoOffsety");
  eucData.drawLines = Properties.getValue("drawLines");

  eucData.wheelBrand = Properties.getValue("wheelBrand_p" + profile);
  eucData.enableBeep = Properties.getValue("enableBeep_p" + profile);
  eucData.gothPWN = Properties.getValue("begodeCF_p" + profile);
  eucData.currentCorrection = Properties.getValue(
    "currentCorrection_p" + profile
  );
  eucData.rotationSpeed = Properties.getValue("rotationSpeed_PWM_p" + profile);
  eucData.rotationVoltage = Properties.getValue(
    "rotationVoltage_PWM_p" + profile
  );
  eucData.powerFactor = Properties.getValue("powerFactor_PWM_p" + profile);
  eucData.voltage_scaling = Properties.getValue(
    "voltageCorrectionFactor_p" + profile
  );
  eucData.speedCorrectionFactor = Properties.getValue(
    "speedCorrectionFactor_p" + profile
  );
  eucData.alarmThreshold_PWM = Properties.getValue(
    "alarmThreshold_PWM_p" + profile
  );
  eucData.alarmThreshold2_PWM = Properties.getValue(
    "alarmThreshold2_PWM_p" + profile
  );
  eucData.alarmThreshold_speed = Properties.getValue(
    "alarmThreshold_speed_p" + profile
  );
  eucData.alarmThreshold_temp = Properties.getValue(
    "alarmThreshold_temp_p" + profile
  );
  eucData.convertToMiles = Properties.getValue("convertToMiles_p" + profile);
  eucData.minCellVolt = Properties.getValue("minCellVolt_p" + profile);

  return true;
  //  Storage.setValue("lastProfileIdx", profile);
}
(:easyconfig)
function setJSONSettings(JSONSettings as Dictionary) {
  // The remote EasyConfig JSON is external, unvalidated data: every block
  // below assumes each present key's value is itself a Dictionary with a
  // "v" entry. If the server (or a stale/edited local copy) ever sends a
  // key without "v", .get("v") returns null and the subsequent
  // toNumber()/toFloat() call throws -- uncaught, that crashes compute().
  // Rather than null-guard ~30 near-identical blocks individually (higher
  // risk of a transcription slip with no EasyConfig test payload on hand to
  // verify against), fail safe the same way Varia's radar call and the BLE
  // decoder calls do elsewhere in this codebase: catch and skip, retried
  // next compute() tick.
  try {
    return parseJSONSettings(JSONSettings);
  } catch (e instanceof Lang.Exception) {
    if (eucData.debug) {
      System.println("setJSONSettings error: " + e.getErrorMessage());
    }
    return false;
  }
}

(:easyconfig)
function parseJSONSettings(JSONSettings as Dictionary) as Boolean {
  // Global Settings (not associated with a specific ProfileName) :
  if (JSONSettings.get("useEngo") != null) {
    eucData.useEngo = (JSONSettings.get("useEngo") as Dictionary).get("v");
  }

  if (JSONSettings.get("engoTouch") != null) {
    eucData.engoTouch = (
      (JSONSettings.get("engoTouch") as Dictionary).get("v") as String
    ).toNumber();
  }
  if (JSONSettings.get("useRadar") != null) {
    eucData.useRadar = (JSONSettings.get("useRadar") as Dictionary).get("v");
  }

  if (JSONSettings.get("variaCloseAlarmDistThr") != null) {
    eucData.variaCloseAlarmDistThr = (
      (JSONSettings.get("variaCloseAlarmDistThr") as Dictionary).get("v") as
        String
    ).toNumber();
  }

  if (JSONSettings.get("variaFarAlarmDistThr") != null) {
    eucData.variaFarAlarmDistThr = (
      (JSONSettings.get("variaFarAlarmDistThr") as Dictionary).get("v") as
        String
    ).toNumber();
  }

  if (JSONSettings.get("motorbikeHeadset") != null) {
    eucData.motorbikeHeadset = (
      JSONSettings.get("motorbikeHeadset") as Dictionary
    ).get("v");
  }

  if (JSONSettings.get("vibeIntensity") != null) {
    eucData.vibeIntensity = (
      (JSONSettings.get("vibeIntensity") as Dictionary).get("v") as String
    ).toNumber();
  }

  if (JSONSettings.get("font") != null) {
    eucData.fontID = (
      (JSONSettings.get("font") as Dictionary).get("v") as String
    ).toNumber();
  }

  if (JSONSettings.get("displayWind") != null) {
    eucData.displayWind = (JSONSettings.get("displayWind") as Dictionary).get(
      "v"
    );
  }

  if (JSONSettings.get("displayNorth") != null) {
    eucData.displayNorth = (JSONSettings.get("displayNorth") as Dictionary).get(
      "v"
    );
  }
  /*
  if (JSONSettings.get("useMiles") != null) {
    eucData.useMiles = (JSONSettings.get("useMiles") as Dictionary).get("v");
  }
  if (JSONSettings.get("useFahrenheit") != null) {
    eucData.useFahrenheit = (
      JSONSettings.get("useFahrenheit") as Dictionary
    ).get("v");
  }
*/
  if (JSONSettings.get("convertToFahrenheit") != null) {
    eucData.convertToFahrenheit = (
      JSONSettings.get("convertToFahrenheit") as Dictionary
    ).get("v");
  }

  if (JSONSettings.get("debugView") != null) {
    eucData.debug = (JSONSettings.get("debugView") as Dictionary).get("v");
  }

  if (JSONSettings.get("logoFill") != null) {
    eucData.logoFill =
      (JSONSettings.get("logoFill") as Dictionary).get("v") as String;
  }

  if (JSONSettings.get("logoEmpty") != null) {
    eucData.logoEmpty =
      (JSONSettings.get("logoEmpty") as Dictionary).get("v") as String;
  }

  if (JSONSettings.get("logoColor") != null) {
    eucData.logoColor = (
      (JSONSettings.get("logoColor") as Dictionary).get("v") as String
    ).toNumberWithBase(16);
  }

  if (JSONSettings.get("linesColor") != null) {
    eucData.linesColor = (
      (JSONSettings.get("linesColor") as Dictionary).get("v") as String
    ).toNumberWithBase(16);
  }

  if (JSONSettings.get("txtColor") != null) {
    eucData.txtColor = (
      (JSONSettings.get("txtColor") as Dictionary).get("v") as String
    ).toNumberWithBase(16);
  }

  if (JSONSettings.get("txtColor_unpr") != null) {
    eucData.txtColor_unpr = (
      (JSONSettings.get("txtColor_unpr") as Dictionary).get("v") as String
    ).toNumberWithBase(16);
  }

  if (JSONSettings.get("logoOffsetx") != null) {
    eucData.logoOffsetx = (
      (JSONSettings.get("logoOffsetx") as Dictionary).get("v") as String
    ).toNumber();
  }
  if (JSONSettings.get("logoOffsety") != null) {
    eucData.logoOffsety = (
      (JSONSettings.get("logoOffsety") as Dictionary).get("v") as String
    ).toNumber();
  }

  if (JSONSettings.get("drawLines") != null) {
    eucData.drawLines = (JSONSettings.get("drawLines") as Dictionary).get("v");
  }

  if (JSONSettings.get("fieldNB") != null) {
    eucData.fieldNB = (
      (JSONSettings.get("fieldNB") as Dictionary).get("v") as String
    ).toNumber();
  }
  if (eucData.fieldNB != null) {
    eucData.fieldIDs = new [eucData.fieldNB];
    for (var i = 0; i < eucData.fieldNB; i++) {
      if (JSONSettings.get("field" + (i + 1)) != null) {
        eucData.fieldIDs[i] = (
          (JSONSettings.get("field" + (i + 1)) as Dictionary).get("v") as String
        ).toNumber();
      } else {
        //  System.println("fallback to default settings for DF-view");
        //fallback to default
        eucData.fieldIDs = [
          Properties.getValue("field1"),
          Properties.getValue("field2"),
          Properties.getValue("field3"),
          Properties.getValue("field4"),
          Properties.getValue("field5"),
          Properties.getValue("field6"),
          Properties.getValue("field7"),
          Properties.getValue("field8"),
        ];
        eucData.fieldNB = Properties.getValue("fieldNB");
        break;
      }
    }
  }
  // end of global Setting

  eucData.loadedProfile = (
    (JSONSettings.get("defaultProfile") as Dictionary).get("v") as String
  ).toNumber();
  if (JSONSettings.get("currentCorrection_p" + eucData.loadedProfile) != null) {
    eucData.currentCorrection = (
      (
        JSONSettings.get("currentCorrection_p" + eucData.loadedProfile) as
          Dictionary
      ).get("v") as String
    ).toNumber();
  }

  if (JSONSettings.get("rotationSpeed_PWM_p" + eucData.loadedProfile) != null) {
    eucData.rotationSpeed = (
      (
        JSONSettings.get("rotationSpeed_PWM_p" + eucData.loadedProfile) as
          Dictionary
      ).get("v") as String
    ).toFloat();
  }
  if (
    JSONSettings.get("rotationVoltage_PWM_p" + eucData.loadedProfile) != null
  ) {
    eucData.rotationVoltage = (
      (
        JSONSettings.get("rotationVoltage_PWM_p" + eucData.loadedProfile) as
          Dictionary
      ).get("v") as String
    ).toFloat();
  }
  if (JSONSettings.get("powerFactor_PWM_p" + eucData.loadedProfile) != null) {
    eucData.powerFactor = (
      (
        JSONSettings.get("powerFactor_PWM_p" + eucData.loadedProfile) as
          Dictionary
      ).get("v") as String
    ).toFloat();
  }
  if (
    JSONSettings.get("voltageCorrectionFactor_p" + eucData.loadedProfile) !=
    null
  ) {
    eucData.voltage_scaling = (
      (
        JSONSettings.get("voltageCorrectionFactor_p" + eucData.loadedProfile) as
          Dictionary
      ).get("v") as String
    ).toFloat();
  }

  if (
    JSONSettings.get("speedCorrectionFactor_p" + eucData.loadedProfile) != null
  ) {
    eucData.speedCorrectionFactor = (
      (
        JSONSettings.get("speedCorrectionFactor_p" + eucData.loadedProfile) as
          Dictionary
      ).get("v") as String
    ).toFloat();
  }
  if (
    JSONSettings.get("alarmThreshold_PWM_p" + eucData.loadedProfile) != null
  ) {
    eucData.alarmThreshold_PWM = (
      (
        JSONSettings.get("alarmThreshold_PWM_p" + eucData.loadedProfile) as
          Dictionary
      ).get("v") as String
    ).toNumber();
  }
  if (
    JSONSettings.get("alarmThreshold2_PWM_p" + eucData.loadedProfile) != null
  ) {
    eucData.alarmThreshold2_PWM = (
      (
        JSONSettings.get("alarmThreshold2_PWM_p" + eucData.loadedProfile) as
          Dictionary
      ).get("v") as String
    ).toNumber();
  }
  if (
    JSONSettings.get("alarmThreshold_speed_p" + eucData.loadedProfile) != null
  ) {
    eucData.alarmThreshold_speed = (
      (
        JSONSettings.get("alarmThreshold_speed_p" + eucData.loadedProfile) as
          Dictionary
      ).get("v") as String
    ).toNumber();
  }
  if (
    JSONSettings.get("alarmThreshold_temp_p" + eucData.loadedProfile) != null
  ) {
    eucData.alarmThreshold_temp = (
      (
        JSONSettings.get("alarmThreshold_temp_p" + eucData.loadedProfile) as
          Dictionary
      ).get("v") as String
    ).toNumber();
  }
  if (JSONSettings.get("wheelBrand_p" + eucData.loadedProfile) != null) {
    eucData.wheelBrand = (
      (
        JSONSettings.get("wheelBrand_p" + eucData.loadedProfile) as Dictionary
      ).get("v") as String
    ).toNumber();
  }
  if (JSONSettings.get("minCellVolt_p" + eucData.loadedProfile) != null) {
    eucData.minCellVolt = (
      (
        JSONSettings.get("minCellVolt_p" + eucData.loadedProfile) as Dictionary
      ).get("v") as String
    ).toFloat();
  }

  /*
  if (JSONSettings.get("wheelName_p" + eucData.loadedProfile) != null) {
    eucData.wheelName = (
      JSONSettings.get("wheelName_p" + eucData.loadedProfile) as Dictionary
    ).get("v");
  }*/
  if (JSONSettings.get("begodeCF_p" + eucData.loadedProfile) != null) {
    eucData.gothPWN = (
      JSONSettings.get("begodeCF_p" + eucData.loadedProfile) as Dictionary
    ).get("v");
  }

  if (JSONSettings.get("convertToMiles_p" + eucData.loadedProfile) != null) {
    eucData.convertToMiles = (
      JSONSettings.get("convertToMiles_p" + eucData.loadedProfile) as Dictionary
    ).get("v");
  }
  return true;
}
(:legacy)
function setJSONSettings(JSONSettings as Dictionary) {}
