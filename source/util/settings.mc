import Toybox.Lang;

function setSettings(profile) {
  eucData.fieldIDs = [
    AppStorage.getSetting("field1"),
    AppStorage.getSetting("field2"),
    AppStorage.getSetting("field3"),
    AppStorage.getSetting("field4"),
    AppStorage.getSetting("field5"),
    AppStorage.getSetting("field6"),
    AppStorage.getSetting("field7"),
    AppStorage.getSetting("field8"),
  ];
  eucData.fieldNB = AppStorage.getSetting("fieldNB");
  eucData.useEngo = AppStorage.getSetting("useEngo");
  eucData.engoTouch = AppStorage.getSetting("engoTouch");

  eucData.useRadar = AppStorage.getSetting("useRadar");
  eucData.convertToFahrenheit = AppStorage.getSetting("convertToFahrenheit");
  eucData.motorbikeHeadset = AppStorage.getSetting("motorbikeHeadset");
  eucData.variaCloseAlarmDistThr = AppStorage.getSetting(
    "variaCloseAlarmDistThr"
  );
  eucData.variaFarAlarmDistThr = AppStorage.getSetting("variaFarAlarmDistThr");
  eucData.displayNorth = AppStorage.getSetting("displayNorth");
  eucData.displayWind = AppStorage.getSetting("displayWind");
  eucData.vibeIntensity = AppStorage.getSetting("vibeIntensity");

  eucData.debug = AppStorage.getSetting("debugView");
  eucData.logoFill = AppStorage.getSetting("logoFill");
  eucData.logoEmpty = AppStorage.getSetting("logoEmpty");
  eucData.logoColor = AppStorage.getSetting("logoColor").toNumberWithBase(16);
  eucData.linesColor = AppStorage.getSetting("linesColor").toNumberWithBase(16);
  eucData.txtColor = AppStorage.getSetting("txtColor").toNumberWithBase(16);
  eucData.txtColor_unpr =
    AppStorage.getSetting("txtColor_unpr").toNumberWithBase(16);
  eucData.fontID = AppStorage.getSetting("font");
  eucData.logoOffsetx = AppStorage.getSetting("logoOffsetx");
  eucData.logoOffsety = AppStorage.getSetting("logoOffsety");
  eucData.drawLines = AppStorage.getSetting("drawLines");
  for (var i = 1; i < 4; i++) {
    eucData.wheelBrand = AppStorage.getSetting("wheelBrand_p" + i);
    eucData.gothPWN = AppStorage.getSetting("begodeCF_p" + i);
    eucData.currentCorrection = AppStorage.getSetting(
      "currentCorrection_p" + i
    );
    eucData.rotationSpeed = AppStorage.getSetting("rotationSpeed_PWM_p" + i);
    eucData.rotationVoltage = AppStorage.getSetting(
      "rotationVoltage_PWM_p" + i
    );
    eucData.powerFactor = AppStorage.getSetting("powerFactor_PWM_p" + i);
    eucData.voltage_scaling = AppStorage.getSetting(
      "voltageCorrectionFactor_p" + i
    );
    eucData.speedCorrectionFactor = AppStorage.getSetting(
      "speedCorrectionFactor_p" + i
    );
    eucData.alarmThreshold_PWM = AppStorage.getSetting(
      "alarmThreshold_PWM_p" + i
    );
    eucData.alarmThreshold2_PWM = AppStorage.getSetting(
      "alarmThreshold2_PWM_p" + i
    );
    eucData.alarmThreshold_speed = AppStorage.getSetting(
      "alarmThreshold_speed_p" + i
    );
    eucData.alarmThreshold_temp = AppStorage.getSetting(
      "alarmThreshold_temp_p" + i
    );
    eucData.convertToMiles = AppStorage.getSetting("convertToMiles_p" + i);
  }

  //  Storage.setValue("lastProfileIdx", profile);
}

function setJSONSettings(JSONSettings as Dictionary) {
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
          AppStorage.getSetting("field1"),
          AppStorage.getSetting("field2"),
          AppStorage.getSetting("field3"),
          AppStorage.getSetting("field4"),
          AppStorage.getSetting("field5"),
          AppStorage.getSetting("field6"),
          AppStorage.getSetting("field7"),
          AppStorage.getSetting("field8"),
        ];
        eucData.fieldNB = AppStorage.getSetting("fieldNB");
        break;
      }
    }
  }
  // end of global Setting

  var profileNb = (
    (JSONSettings.get("defaultProfile") as Dictionary).get("v") as String
  ).toNumber();
  if (JSONSettings.get("currentCorrection_p" + profileNb) != null) {
    eucData.currentCorrection = (
      (JSONSettings.get("currentCorrection_p" + profileNb) as Dictionary).get(
        "v"
      ) as String
    ).toNumber();
  }

  if (JSONSettings.get("rotationSpeed_PWM_p" + profileNb) != null) {
    eucData.rotationSpeed = (
      (JSONSettings.get("rotationSpeed_PWM_p" + profileNb) as Dictionary).get(
        "v"
      ) as String
    ).toFloat();
  }
  if (JSONSettings.get("rotationVoltage_PWM_p" + profileNb) != null) {
    eucData.rotationVoltage = (
      (JSONSettings.get("rotationVoltage_PWM_p" + profileNb) as Dictionary).get(
        "v"
      ) as String
    ).toFloat();
  }
  if (JSONSettings.get("powerFactor_PWM_p" + profileNb) != null) {
    eucData.powerFactor = (
      (JSONSettings.get("powerFactor_PWM_p" + profileNb) as Dictionary).get(
        "v"
      ) as String
    ).toFloat();
  }
  if (JSONSettings.get("voltageCorrectionFactor_p" + profileNb) != null) {
    eucData.voltage_scaling = (
      (
        JSONSettings.get("voltageCorrectionFactor_p" + profileNb) as Dictionary
      ).get("v") as String
    ).toFloat();
  }

  if (JSONSettings.get("speedCorrectionFactor_p" + profileNb) != null) {
    eucData.speedCorrectionFactor = (
      (
        JSONSettings.get("speedCorrectionFactor_p" + profileNb) as Dictionary
      ).get("v") as String
    ).toFloat();
  }
  if (JSONSettings.get("alarmThreshold_PWM_p" + profileNb) != null) {
    eucData.alarmThreshold_PWM = (
      (JSONSettings.get("alarmThreshold_PWM_p" + profileNb) as Dictionary).get(
        "v"
      ) as String
    ).toNumber();
  }
  if (JSONSettings.get("alarmThreshold2_PWM_p" + profileNb) != null) {
    eucData.alarmThreshold2_PWM = (
      (JSONSettings.get("alarmThreshold2_PWM_p" + profileNb) as Dictionary).get(
        "v"
      ) as String
    ).toNumber();
  }
  if (JSONSettings.get("alarmThreshold_speed_p" + profileNb) != null) {
    eucData.alarmThreshold_speed = (
      (
        JSONSettings.get("alarmThreshold_speed_p" + profileNb) as Dictionary
      ).get("v") as String
    ).toNumber();
  }
  if (JSONSettings.get("alarmThreshold_temp_p" + profileNb) != null) {
    eucData.alarmThreshold_temp = (
      (JSONSettings.get("alarmThreshold_temp_p" + profileNb) as Dictionary).get(
        "v"
      ) as String
    ).toNumber();
  }
  if (JSONSettings.get("wheelBrand_p" + profileNb) != null) {
    eucData.wheelBrand = (
      (JSONSettings.get("wheelBrand_p" + profileNb) as Dictionary).get("v") as
        String
    ).toNumber();
  }
  /*
  if (JSONSettings.get("wheelName_p" + profileNb) != null) {
    eucData.wheelName = (
      JSONSettings.get("wheelName_p" + profileNb) as Dictionary
    ).get("v");
  }*/
  if (JSONSettings.get("begodeCF_p" + profileNb) != null) {
    eucData.gothPWN = (
      JSONSettings.get("begodeCF_p" + profileNb) as Dictionary
    ).get("v");
  }

  if (JSONSettings.get("convertToMiles_p" + profileNb) != null) {
    eucData.convertToMiles = (
      JSONSettings.get("convertToMiles_p" + profileNb) as Dictionary
    ).get("v");
  }
  return true;
}
