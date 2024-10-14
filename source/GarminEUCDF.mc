import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;
using Toybox.Math;
import Toybox.System;
using Toybox.Application.Storage;
class GarminEUCDF extends WatchUi.DataField {
  var bleDelegate;
  var fill_logo;
  var empty_logo;
  var delay = 3;
  // var firstCall = true;

  var fieldNB;
  var fieldIDs;
  var fieldNames;
  var fieldValues;
  const SPEED_FIELD_ID = 0;
  const PWM_FIELD_ID = 1;
  const VOLTAGE_FIELD_ID = 2;
  const TEMP_FIELD_ID = 5;
  const TRIPDISTANCE_FIELD_ID = 6;
  const AVGMVSPEED_FIELD_ID = 7;
  const AVGSPEED_FIELD_ID = 8;
  const MAXSPEED_FIELD_ID = 9;
  const MAXPWM_FIELD_ID = 10;
  const MAXTEMP_FIELD_ID = 16;
  const MINBATTERY_FIELD_ID = 19;
  const AVGUSEDBATTERY_FIELD_ID = 21;
  const EORBATTERY_FIELD_ID = 22;

  const VEH_RELATIVE_SPD_ID = 23;
  const VEH_TOTAL_CNT_ID = 24;

  var mSpeedField = null;
  var mPWMField = null;
  var mVoltageField = null;

  var mTempField = null;
  var mTripDistField = null;
  var mAvgMvSpeedField = null;
  var mMaxSpeedField = null;
  var mMaxPWMField = null;

  var mMaxTempField = null;

  var mAvgSpeedField = null;

  var mMinBatteryField = null;

  var mAvgUsedBatteryField = null;
  var mEORBatteryField = null;
  var mVehRelativeSpdField = null;
  var mVehTotalCntField = null;
  var _alertDisplayed = false;
  var nb_Font;

  var engoBattReq = 60;
  var turnId = null;
  var prevTurnId = "";
  var nextPointName = null;
  var nextPointDistance = null;
  // var navigationData = null;
  //var RadarConnState = -1;
  private var cDrawables = {};

  function initialize(_bleDelegate) {
    bleDelegate = _bleDelegate;
    DataField.initialize();
    fieldsInitialize();
    //load custom number font
    if (eucData.fontID == 0) {
      nb_Font = WatchUi.loadResource(Rez.Fonts.Roboto);
    } else {
      nb_Font = WatchUi.loadResource(Rez.Fonts.Rajdhani);
    }

    // draw logo
    if (eucData.logoFill.length() > 10) {
      fill_logo = stringToArrays(eucData.logoFill);
    }
    if (eucData.logoEmpty.length() > 10) {
      empty_logo = stringToArrays(eucData.logoEmpty);
    }

    // System.println(fill_logo);
    eucData.logoFill = ""; // cleaning doesn't free memory, probably useless
    eucData.logoEmpty = "";
  }
  /*
  function onLayout(dc) as Void {
    if (eucData.GUI == true) {
      setLayout(Rez.Layouts.HomeLayout(dc));

      // Label drawables
      cDrawables[:TimeDate] = View.findDrawableById("TimeDate");
      cDrawables[:SpeedNumber] = View.findDrawableById("SpeedNumber");
      cDrawables[:BatteryNumber] = View.findDrawableById("BatteryNumber");
      cDrawables[:TemperatureNumber] =
        View.findDrawableById("TemperatureNumber");
      cDrawables[:BottomSubtitle] = View.findDrawableById("BottomSubtitle");
      // And arc drawables
      cDrawables[:SpeedArc] = View.findDrawableById("SpeedDial"); // used for PMW
      cDrawables[:BatteryArc] = View.findDrawableById("BatteryArc");
      cDrawables[:TemperatureArc] = View.findDrawableById("TemperatureArc");
      cDrawables[:RecordingIndicator] =
        View.findDrawableById("RecordingIndicator");
    }
  }*/
  public function restoreValues(
    _maxTemp,
    _minTemp,
    _maxVoltage,
    _minVoltage,
    _maxBatteryPerc,
    _minBatteryPerc,
    _sessionDistance,
    _avgSpeed,
    _maxPWM,
    _movingmsec
    // _startingMoment
  ) {
    maxTemp = _maxTemp;
    minTemp = _minTemp;
    maxVoltage = _maxVoltage;
    minVoltage = _minVoltage;
    maxBatteryPerc = _maxBatteryPerc;
    minBatteryPerc = _minBatteryPerc;
    sessionDistance = _sessionDistance;
    avgSpeed = _avgSpeed;
    maxPWM = _maxPWM;
    movingmsec = _movingmsec;
    // startingMoment = _startingMoment;
  }
  function fieldsInitialize() {
    fieldIDs = [
      AppStorage.getSetting("field1"),
      AppStorage.getSetting("field2"),
      AppStorage.getSetting("field3"),
      AppStorage.getSetting("field4"),
      AppStorage.getSetting("field5"),
      AppStorage.getSetting("field6"),
      AppStorage.getSetting("field7"),
      AppStorage.getSetting("field8"),
    ];
    fieldNB = AppStorage.getSetting("fieldNB");

    fieldNames = new [fieldNB];
    fieldValues = new [fieldNB];
    for (var i = 0; i < fieldNB; i++) {
      fieldNames[i] = "NC";
      fieldValues[i] = "--";
    }
    mSpeedField = createField(
      "speed",
      SPEED_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "km/h" }
    );

    mPWMField = createField(
      "PWM",
      PWM_FIELD_ID,
      FitContributor.DATA_TYPE_UINT8,
      { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "%" }
    );
    mVoltageField = createField(
      "Voltage",
      VOLTAGE_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "V" }
    );
    mTempField = createField(
      "Temperature",
      TEMP_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "°C" }
    );
    mMaxTempField = createField(
      "Max_Temp",
      MAXTEMP_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "°C" }
    );
    mTripDistField = createField(
      "TripDistance",
      TRIPDISTANCE_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "km" }
    );
    mAvgMvSpeedField = createField(
      "AvgMvSpeed",
      AVGMVSPEED_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "km/h" }
    );
    mMaxSpeedField = createField(
      "Max_speed",
      MAXSPEED_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "km/h" }
    );

    mMaxPWMField = createField(
      "Max_PWM",
      MAXPWM_FIELD_ID,
      FitContributor.DATA_TYPE_UINT8,
      { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "%" }
    );

    mAvgSpeedField = createField(
      "Avg_Speed",
      AVGSPEED_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "km/h" }
    );
    mMinBatteryField = createField(
      "Min_Battery",
      MINBATTERY_FIELD_ID,
      FitContributor.DATA_TYPE_UINT8,
      { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "%" }
    );
    mEORBatteryField = createField(
      "EORBattery",
      EORBATTERY_FIELD_ID,
      FitContributor.DATA_TYPE_UINT8,
      { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "%" }
    );
    mAvgUsedBatteryField = createField(
      "AvgUsedBattery",
      AVGUSEDBATTERY_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "%/km" }
    );

    if (eucData.useRadar == true) {
      if (eucData.radar != null) {
        try {
          //RadarConnState = eucData.radar.getDeviceState().state;
          //   if (RadarConnState > 2) {
          mVehRelativeSpdField = createField(
            "VehRelativeSpd",
            VEH_RELATIVE_SPD_ID,
            FitContributor.DATA_TYPE_UINT8,
            { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "" }
          );
          mVehTotalCntField = createField(
            "VehTotalCnt",
            VEH_TOTAL_CNT_ID,
            FitContributor.DATA_TYPE_UINT16,
            { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "" }
          );
          //    }
        } catch (e instanceof Lang.Exception) {
          // System.println(e.getErrorMessage());
        }
      }
    }

    // set fields to 0

    // V0.0.38
    mSpeedField.setData(0.0);
    mPWMField.setData(0.0);
    //mVoltageField.setData(0.0);
    mTempField.setData(0.0);
    mTripDistField.setData(0.0);
    mMaxSpeedField.setData(0.0);
    mMaxPWMField.setData(0.0);
    mMaxTempField.setData(0.0);
    mAvgSpeedField.setData(0.0);
    // mMinVoltageField.setData(0.0);
    // mMaxVoltageField.setData(0.0);
    //  mMaxBatteryField.setData(0.0);
    mMinBatteryField.setData(0.0);
    //    mMinTempField.setData(0.0);
  }

  var maxSpeed = 0.0;
  var maxPWM = 0.0;
  var maxCurrent = 0.0;
  var maxPower = 0.0;
  var maxTemp = -255.0;
  var minTemp = 255.0;
  var currentCurrent = 0.0;
  var currentVoltage = 0.0;
  var currentBatteryPerc = 0.0;
  var sumCurrent = 0.0;
  var callNb = 0.0;
  var currentPower = 0.0;
  var sumPower = 0.0;
  var sessionDistance = 0.0;
  var startingEUCTripDistance = 0;
  //var startingMoment = 0.0;
  var minVoltage = 255.0;
  var maxVoltage = 0.0;
  var minBatteryPerc = 101.0;
  var maxBatteryPerc = 0.0;
  var avgSpeed = 0.0;
  var avgCurrent = 0.0;
  var avgPower = 0.0;
  var movingmsec = 0.0;
  var averageMovingSpeed = 0.0;
  var EUCBatteryPercStart = null;
  var batteryUsg = 0;
  var currentbatteryUsg = 0;
  var batteryUsgValues = new [0];
  function updateFitData(garminInfo) {
    callNb++;
    currentVoltage = eucData.getVoltage();
    currentBatteryPerc = eucData.getBatteryPercentage();
    eucData.PWM = eucData.getPWM();
    eucData.correctedSpeed = eucData.getCorrectedSpeed();

    currentCurrent = eucData.getCurrent();
    currentPower = currentCurrent * currentVoltage;

    mSpeedField.setData(eucData.correctedSpeed); // id 0
    mPWMField.setData(eucData.PWM); //id 1
    mVoltageField.setData(currentVoltage); // id 2
    //    mCurrentField.setData(currentCurrent); // id 3
    //    mPowerField.setData(currentPower); // id 4
    mTempField.setData(eucData.temperature); // id 5
    if (currentBatteryPerc > 0 && eucData.paired == true) {
      mEORBatteryField.setData(currentBatteryPerc);
    }
    if (eucData.correctedSpeed > maxSpeed) {
      maxSpeed = eucData.correctedSpeed;
      mMaxSpeedField.setData(maxSpeed); // id 7
    }
    if (eucData.PWM > maxPWM) {
      maxPWM = eucData.PWM;
      mMaxPWMField.setData(maxPWM); // id 8
    }
    if (currentCurrent > maxCurrent) {
      maxCurrent = currentCurrent;
      // mMaxCurrentField.setData(maxCurrent); // id 9
    }
    if (currentPower > maxPower) {
      maxPower = currentPower;
      //   mMaxPowerField.setData(maxPower); // id 10
    }

    if (eucData.temperature > maxTemp) {
      maxTemp = eucData.temperature;
      mMaxTempField.setData(maxTemp); // id 11
    }
    if (eucData.temperature < minTemp && eucData.temperature != 0.0) {
      minTemp = eucData.temperature;
      // mMinTempField.setData(minTemp); // id 11
    }

    if (currentVoltage > maxVoltage && currentVoltage != 0.0) {
      maxVoltage = currentVoltage;
      //     mMaxVoltageField.setData(maxVoltage);
    }
    if (currentVoltage < minVoltage && currentVoltage != 0.0) {
      minVoltage = currentVoltage;
      //   mMinVoltageField.setData(minVoltage);
    }

    if (currentBatteryPerc > maxBatteryPerc) {
      maxBatteryPerc = currentBatteryPerc;
      // mMaxBatteryField.setData(maxBatteryPerc);
    }
    if (currentBatteryPerc < minBatteryPerc && currentBatteryPerc != 0.0) {
      minBatteryPerc = currentBatteryPerc;
      mMinBatteryField.setData(minBatteryPerc);
    }

    // var currentMoment = new Time.Moment(Time.now().value());
    // var elapsedTime = startingMoment.subtract(currentMoment);
    var elapsedTime = garminInfo.timerTime / 1000.0; // convert to seconds
    //System.println("elaspsed :" + elapsedTime.value());
    if (elapsedTime != 0 && eucData.totalDistance > 0) {
      //if (elapsedTime.value() != 0 && eucData.totalDistance > 0) {
      if (startingEUCTripDistance == 0) {
        startingEUCTripDistance = eucData.totalDistance;
      }
      sessionDistance =
        (eucData.totalDistance - startingEUCTripDistance) *
        eucData.speedCorrectionFactor;
      //avgSpeed = sessionDistance / (elapsedTime.value() / 3600.0);
      avgSpeed = sessionDistance / (elapsedTime / 3600.0);
    } else {
      sessionDistance = 0.0;
      avgSpeed = 0.0;
    }
    mTripDistField.setData(sessionDistance); // id 6

    mAvgSpeedField.setData(avgSpeed); // id 12

    sumCurrent = sumCurrent + currentCurrent;
    sumPower = sumPower + currentPower;
    avgCurrent = sumCurrent / callNb;
    avgPower = sumPower / callNb;

    if (eucData.correctedSpeed > 2.5) {
      movingmsec = movingmsec + 1000;
      averageMovingSpeed = sessionDistance / (movingmsec / 3600000.0);
    }

    mAvgMvSpeedField.setData(averageMovingSpeed);
    //mAvgPowerField.setData(sumPower / callNb); // id 14

    if (currentBatteryPerc > 0) {
      if (EUCBatteryPercStart == null) {
        EUCBatteryPercStart = currentBatteryPerc;
      } else {
        if (EUCBatteryPercStart < currentBatteryPerc) {
          EUCBatteryPercStart = currentBatteryPerc;
        }
      }
      if (sessionDistance > 0) {
        currentbatteryUsg =
          (EUCBatteryPercStart - currentBatteryPerc) / sessionDistance;
        batteryUsgValues.add(currentbatteryUsg);
        if (batteryUsgValues.size() > 10) {
          batteryUsgValues = batteryUsgValues.slice(1, batteryUsgValues.size());
          var tempBatteryUsg = 0;
          var valueCnt = 0;
          for (var i = 0; i < batteryUsgValues.size(); i++) {
            var currentBatteryUsg = batteryUsgValues[i];
            if (currentBatteryUsg != null) {
              tempBatteryUsg = tempBatteryUsg + currentBatteryUsg;
              valueCnt++;
            }
          }
          if (valueCnt != 0) {
            batteryUsg = tempBatteryUsg / valueCnt;
          }

          mAvgUsedBatteryField.setData(batteryUsg);
        }
      }
    }

    if (eucData.useRadar == true) {
      mVehRelativeSpdField.setData(eucData.variaTargetSpeed);
      mVehTotalCntField.setData(eucData.totalVehCount);
    }
  }
  function resetVariables() {
    //System.println("reset variables");
    //startingMoment = new Time.Moment(Time.now().value());
    maxSpeed = 0.0;
    maxPWM = 0.0;
    maxCurrent = 0.0;
    maxPower = 0.0;
    maxTemp = -255.0;
    minTemp = 255.0;
    eucData.PWM = 0.0;
    eucData.correctedSpeed = 0.0;
    currentCurrent = 0.0;
    currentVoltage = 0.0;
    currentBatteryPerc = 0.0;
    sumCurrent = 0.0;
    callNb = 0.0;
    currentPower = 0.0;
    sumPower = 0.0;
    sessionDistance = 0.0;
    startingEUCTripDistance = 0;
    minVoltage = 255.0;
    maxVoltage = 0.0;
    minBatteryPerc = 101.0;
    maxBatteryPerc = 0.0;
    avgSpeed = 0.0;
    avgCurrent = 0.0;
    avgPower = 0.0;
  }
  function getFieldValues() {
    for (var field_id = 0; field_id < fieldNB; field_id++) {
      if (fieldIDs[field_id] == 0) {
        fieldNames[field_id] = "SPEED";
        fieldValues[field_id] = valueRound(eucData.correctedSpeed, "%.1f");
      }
      if (fieldIDs[field_id] == 1) {
        fieldNames[field_id] = "VOLTAGE";
        fieldValues[field_id] = valueRound(currentVoltage, "%.1f");
      }
      if (fieldIDs[field_id] == 2) {
        fieldNames[field_id] = "TRP DIST";
        fieldValues[field_id] = valueRound(sessionDistance, "%.1f");
      }
      if (fieldIDs[field_id] == 3) {
        fieldNames[field_id] = "CURR";
        fieldValues[field_id] = valueRound(currentCurrent, "%.1f");
      }
      if (fieldIDs[field_id] == 4) {
        fieldNames[field_id] = "TEMP";
        fieldValues[field_id] = valueRound(eucData.temperature, "%.1f");
      }
      if (fieldIDs[field_id] == 5) {
        fieldNames[field_id] = "TT DIST";
        fieldValues[field_id] = valueRound(eucData.totalDistance, "%.1f");
      }
      if (fieldIDs[field_id] == 6) {
        fieldNames[field_id] = "PWM";
        fieldValues[field_id] = valueRound(eucData.PWM, "%.1f");
      }
      if (fieldIDs[field_id] == 7) {
        fieldNames[field_id] = "BATT %";
        fieldValues[field_id] = valueRound(currentBatteryPerc, "%.1f");
      }
      if (fieldIDs[field_id] == 8) {
        fieldNames[field_id] = "BATT USG";
        fieldValues[field_id] = valueRound(batteryUsg, "%.1f");
      }
      if (fieldIDs[field_id] == 9) {
        fieldNames[field_id] = "MIN TEMP";
        fieldValues[field_id] = valueRound(minTemp, "%.1f");
      }
      if (fieldIDs[field_id] == 10) {
        fieldNames[field_id] = "MAX TEMP";
        fieldValues[field_id] = valueRound(maxTemp, "%.1f");
      }
      if (fieldIDs[field_id] == 11) {
        fieldNames[field_id] = "MAX SPD";
        fieldValues[field_id] = valueRound(maxSpeed, "%.1f");
      }
      if (fieldIDs[field_id] == 12) {
        fieldNames[field_id] = "AVG SPD";
        fieldValues[field_id] = valueRound(avgSpeed, "%.1f");
      }
      if (fieldIDs[field_id] == 13) {
        fieldNames[field_id] = "AVG MV SPD";
        fieldValues[field_id] = valueRound(averageMovingSpeed, "%.1f");
      }
      if (fieldIDs[field_id] == 14) {
        fieldNames[field_id] = "MIN VOLT";
        fieldValues[field_id] = valueRound(minVoltage, "%.1f");
      }
      if (fieldIDs[field_id] == 15) {
        fieldNames[field_id] = "MAX VOLT";
        fieldValues[field_id] = valueRound(maxVoltage, "%.1f");
      }
      if (fieldIDs[field_id] == 16) {
        fieldNames[field_id] = "MAX CURR";
        fieldValues[field_id] = valueRound(maxCurrent, "%.1f");
      }
      if (fieldIDs[field_id] == 17) {
        fieldNames[field_id] = "AVG CURR";
        fieldValues[field_id] = valueRound(avgCurrent, "%.1f");
      }
      if (fieldIDs[field_id] == 18) {
        fieldNames[field_id] = "MIN BATT %";
        fieldValues[field_id] = valueRound(minBatteryPerc, "%.1f");
      }
      if (fieldIDs[field_id] == 19) {
        fieldNames[field_id] = "MAX BATT %";
        fieldValues[field_id] = valueRound(maxBatteryPerc, "%.1f");
      }
      if (fieldIDs[field_id] == 20) {
        fieldNames[field_id] = "AVG PWR";
        fieldValues[field_id] = valueRound(avgPower, "%.1f");
      }
      if (fieldIDs[field_id] == 21) {
        fieldNames[field_id] = "MAX PWR";
        fieldValues[field_id] = valueRound(maxPower, "%.1f");
      }
      if (fieldIDs[field_id] == 22) {
        fieldNames[field_id] = "VEH SPD";
        var targetSpeed = eucData.variaTargetSpeed;
        if (targetSpeed != null) {
          targetSpeed = targetSpeed * 3.6; //Km/h only here, should implement mph when adding imperial unit support
        }
        fieldValues[field_id] = valueRound(targetSpeed, "%.1f");
      }
      if (fieldIDs[field_id] == 23) {
        fieldNames[field_id] = "VEH DST";
        fieldValues[field_id] = valueRound(eucData.variaTargetDist, "%.1f");
      }
      if (fieldIDs[field_id] == 24) {
        fieldNames[field_id] = "VEH NB";
        fieldValues[field_id] = valueRound(eucData.variaTargetNb, "%1d");
      }
      if (fieldIDs[field_id] == 25) {
        fieldNames[field_id] = "RD V";
        fieldValues[field_id] = valueRound(getVariaVoltage(), "%.1f");
      }
      if (fieldIDs[field_id] == 26) {
        fieldNames[field_id] = "TIME";
        var CurrentTime = System.getClockTime();

        fieldValues[field_id] =
          CurrentTime.hour.format("%d") + ":" + CurrentTime.min.format("%02d");
      }
      if (fieldIDs[field_id] == 27) {
        fieldNames[field_id] = "GPS SPD";
        var GPS_speed = Position.getInfo().speed;

        fieldValues[field_id] = valueRound(GPS_speed, "%.1f");
      }
    }
  }
  // Calculate the data to display in the field here
  var activityElapsedTime = "";
  var activityElapsedDist = "";
  var activityTimerState = "";
  var activityTimerTime = "";
  var reset = "no";
  // Calculate the data to display in the field here
  //var fakeVariaObj;
  function compute(info) {
    if (info.elapsedTime != null) {
      activityElapsedTime = info.elapsedTime;
    }
    if (info.elapsedDistance != null) {
      activityElapsedDist = info.elapsedDistance;
    }

    if (info.timerState != null) {
      activityTimerState = info.timerState;
    }
    if (info.timerTime != null) {
      activityTimerTime = info.timerTime;
    }
    eucData.timerState = activityTimerState;
    if (eucData.useEngo == true) {
      engoUpdate();
      // check if cfg config is beeing updated to display a message :

      if (info.distanceToNextPoint != null) {
        nextPointDistance = info.distanceToNextPoint;
      } else {
        nextPointDistance = null;
        eucData.engoPageNb = 2; // remove navig view
      }
      if (info.nameOfNextPoint != null && info.nameOfNextPoint.length() > 0) {
        nextPointName = info.nameOfNextPoint.substring(1, null);
        turnId = info.nameOfNextPoint.substring(0, 1);
      } else {
        nextPointName = null;
        turnId = null;
      }
    }
    //System.println("nextPointName: " + nextPointName);
    //System.println("nextPointDistance: " + nextPointDistance);
    //System.println("turnId: " + turnId);

    //eucData.paired = true;

    if (eucData.paired == true) {
      if (delay < 0) {
        updateFitData(info);
        getFieldValues();
        /*
        EUCAlarms.checkAlarms();
        
        if (fakeVariaObj != null) {
          fakeVariaObj = variaMove(fakeVariaObj);
          Varia.processTarget(fakeVariaObj);
          Varia.processTarget(fakeVariaObj);
          Varia.processTarget(fakeVariaObj);
          Varia.processTarget(fakeVariaObj);
        }*/
      } else {
        //  fakeVariaObj = fakeVaria(3);
        /*
        if (AppStorage.getSetting("resumeDectectionMethod") == 0) {
          if (info.elapsedTime == null || info.elapsedTime < 300000) {
            resetVariables();
            reset = "yes";
          }
        }
        if (AppStorage.getSetting("resumeDectectionMethod") == 1) {
          // if activity is not started yet
          */
        if (info.timerState == 1) {
          loadStoredValues();
        }
        /* V0.0.38
        else {
          resetVariables();
          reset = true;
        }*/
      }
      // }
      //System.println(info.averageSpeed);

      delay = delay - 1;
    } else {
      if (
        eucData.useRadar == true &&
        eucData.radar != null &&
        eucData.timerState == 3
      ) {
        try {
          Varia.processTarget(eucData.radar.getRadarInfo()); // surrounding by try because varia may disconnect (unexpected crashes were observed)
        } catch (e instanceof Lang.Exception) {
          // System.println(e.getErrorMessage());
        }
      }
      /*
      delay = delay - 1; //to remove
      if (delay == -10) {
        onTimerStart();
      }
      if (delay == -20) {
        onTimerStop();
      }
      if (delay == -30) {
        onTimerReset();
      }*/
    }
  }
  function getVariaVoltage() {
    var variaVoltage = null;
    var batteryStats = null;
    if (
      eucData.useRadar == true &&
      eucData.radar != null &&
      eucData.timerState == 3
    ) {
      try {
        batteryStats = eucData.radar.getBatteryStatus(null);
        if (batteryStats != null) {
          variaVoltage = batteryStats.batteryVoltage;
        }
      } catch (e instanceof Lang.Exception) {
        // System.println(e.getErrorMessage());
      }
    }
    return variaVoltage;
  }

  function engoUpdate() {
    //engo related code
    if (
      eucData.useEngo == true &&
      eucData.engoPaired == true &&
      bleDelegate.engoDisplayInit == true
    ) {
      engoBattReq = engoBattReq + 1;
      if (engoBattReq > 60) {
        engoBattReq = 0;
        bleDelegate.getEngoBattery();
      }
      var textArray = new [6];

      // var xpos = 225;
      var currentTime = System.getClockTime();
      if (eucData.engoBattery != null) {
        textArray[0] = getHexText(eucData.engoBattery + " %", 0, 0);
      } else {
        textArray[0] = getHexText(" ", 0, 0);
      }

      textArray[1] = getHexText(
        currentTime.hour.format("%02d") + ":" + currentTime.min.format("%02d"),
        0,
        0
      );
      if (eucData.engoPage == 1) {
        prevTurnId = null;
        textArray[2] = getHexText(valueRound(eucData.PWM, "%.1f") + " %", 0, 1);
        textArray[3] = getHexText(
          valueRound(eucData.correctedSpeed, "%.1f") + " km/h",
          0,
          1
        );
        textArray[4] = getHexText(
          valueRound(eucData.temperature, "%.1f") + " *C",
          0,
          1
        );
        textArray[5] = getHexText(
          valueRound(currentBatteryPerc, "%.1f") + " %",
          0,
          1
        );
      }
      if (eucData.engoPage == 2) {
        //Chrono page 1
        prevTurnId = null;
        var chrono;
        if (activityTimerTime != null) {
          var sec = activityTimerTime / 1000;
          var mn = sec / 60;
          chrono = [mn / 60, mn % 60, sec % 60, activityTimerTime % 1000];
        } else {
          chrono = null;
        }
        textArray[2] = getHexText(
          chrono[0].format("%02d") +
            ":" +
            chrono[1].format("%02d") +
            ":" +
            chrono[2].format("%02d"),
          0,
          1
        );
        textArray[3] = getHexText(
          valueRound(sessionDistance, "%.1f") + " km",
          0,
          1
        );
        textArray[4] = getHexText(
          valueRound(averageMovingSpeed, "%.1f") + " km/h",
          0,
          1
        );
        textArray[5] = getHexText(valueRound(maxSpeed, "%.1f") + " km/h", 0, 1);
      }
      if (eucData.engoPage == 3) {
        //Chrono page 1
        if (nextPointDistance != null) {
          textArray[2] = getHexText(
            valueRound(nextPointDistance, "%.1f") + " m",
            0,
            0
          );
        } else {
          textArray[2] = getHexText("", 0, 0);
        }
        if (nextPointName != null) {
          var multiLineName = multiline(nextPointName);
          //  System.println(multiLineName);
          textArray[3] = getHexText(multiLineName[0], 0, 0);
          textArray[4] = getHexText(multiLineName[1], 0, 0);
        } else {
          //System.println("NameNull");
          //implement word wrap
          textArray[3] = getHexText("", 0, 0); // si plus de 20 char word wrap et ligne suivante!
          textArray[4] = getHexText("", 0, 0);
        }
        textArray = textArray.slice(0, 5);

        if (turnId != null) {
          if (!turnId.equals(prevTurnId)) {
            prevTurnId = turnId;
            //    System.println("prevId " + prevTurnId);
            //    System.println("Id " + turnId);

            var imgId = directionDict.get(turnId);
            if (imgId != null) {
              // System.println("updating nav img");
              var imgCmd = getImgCmd(imgId, 130, 150);
              //  System.println(imgCmd);

              bleDelegate.sendCommands(
                concatCmd([getClearRectCmd(130, 150, 190, 210, 0), imgCmd])
              );
            }
          }
        }
      }

      var data = pagePayload(textArray);
      /*
      var currentTime = System.getClockTime();
      var cmdTime = getWriteCmd(
        currentTime.hour.format("%02d") + ":" + currentTime.min.format("%02d"),
        100,
        210,
        4,
        1,
        0x0f
      );
*/
      // System.println(getPageCmd(data, eucData.engoPage));
      bleDelegate.sendCommands(getPageCmd(data, eucData.engoPage));
      //    bleDelegate.sendCommands(cmdTime);
    }
  }

  // Update the field layout and display the field data
  function onUpdate(dc) {
    // DEBUG SCREEN
    if (eucData.debug) {
      /*
      var alignAxe = dc.getWidth() / 5;
      var space = dc.getHeight() / 10;
      var yGap = dc.getHeight() / 8;
      var xGap = dc.getWidth() / 12;
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
      dc.clear();
      dc.drawText(
        alignAxe,
        yGap,
        Graphics.FONT_TINY,
        "ElpsTm: " + activityElapsedTime,
        Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
      );
      dc.drawText(
        alignAxe - xGap,
        space + yGap,
        Graphics.FONT_TINY,
        "ElpsDst: " + activityElapsedDist,
        Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
      );
      dc.drawText(
        alignAxe - 2 * xGap,
        2 * space + yGap,
        Graphics.FONT_TINY,
        "CarNb: " + eucData.variaTargetNb,
        Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
      );

      dc.drawText(
        alignAxe - 2 * xGap,
        5 * space + yGap,
        Graphics.FONT_TINY,
        "TmrSte: " + activityTimerState,
        Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
      );
      dc.drawText(
        alignAxe - xGap,
        6 * space + yGap,
        Graphics.FONT_TINY,
        "TmrTme: " + activityTimerTime,
        Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
      );
      dc.drawText(
        alignAxe,
        7 * space + yGap,
        Graphics.FONT_TINY,
        "rstOcc: " + reset,
        Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
      ); // END OF DEBUG SCREEN
      */
    } else {
      // System.println(eucData.isFirst);
      if (eucData.isFirst && !eucData.paired) {
        var textToDisplay =
          "Profile " +
          eucData.profile +
          " 1st connection\nPlease turn on your wheel\n and wait for connection\n\nensure only one wheel is ON!\n\nIf you enjoy this app :\n ko-fi.com/wheeldash";
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        dc.drawText(
          dc.getWidth() / 2,
          dc.getHeight() / 2,
          Graphics.FONT_SYSTEM_XTINY,
          textToDisplay,
          Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
      } else if (eucData.isFirst && eucData.paired && delay > 0) {
        var textToDisplay =
          "Profile " +
          eucData.profile +
          " connected.\n\nSaving wheel footprint...";
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        dc.drawText(
          dc.getWidth() / 2,
          dc.getHeight() / 2,
          Graphics.FONT_XTINY,
          textToDisplay,
          Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
      } else {
        var scr_height = dc.getHeight();
        var scr_width = dc.getWidth();
        if (fieldNB == 6) {
          var gap;
          var fieldNameFont = Graphics.FONT_XTINY;
          var fieldValueFont = nb_Font;
          var fieldNameFontHeight = Graphics.getFontHeight(fieldNameFont);
          var fieldValueFontHeight = Graphics.getFontHeight(fieldValueFont);
          if (scr_width < 260) {
            gap = dc.getWidth() / 80;
            fieldNameFontHeight = fieldNameFontHeight - 4;
          } else {
            gap = dc.getWidth() / 40;
          }
          dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
          dc.clear();
          drawBackground(dc);
          if (eucData.drawLines) {
            dc.setColor(eucData.linesColor, Graphics.COLOR_BLACK);
            dc.drawLine(gap, scr_height / 2, scr_width - gap, scr_height / 2);
            dc.drawLine(
              scr_width / 2,
              2 * gap + (fieldNameFontHeight + fieldValueFontHeight),
              scr_width / 2,
              scr_height / 2 - 2 * gap
            );
            dc.drawLine(
              scr_width / 2,
              scr_height / 2 + 2 * gap,
              scr_width / 2,
              scr_height -
                2 * gap -
                (fieldNameFontHeight + fieldValueFontHeight)
            );
          }
          if (eucData.paired == true) {
            dc.setColor(eucData.txtColor, Graphics.COLOR_TRANSPARENT);
          } else {
            dc.setColor(eucData.txtColor_unpr, Graphics.COLOR_TRANSPARENT);
          }

          dc.drawText(
            scr_width / 2,
            gap,
            fieldNameFont,
            fieldNames[0],
            Graphics.TEXT_JUSTIFY_CENTER
          );
          dc.drawText(
            scr_width / 2,
            gap + fieldNameFontHeight,
            fieldValueFont,
            fieldValues[0],
            Graphics.TEXT_JUSTIFY_CENTER
          );

          dc.drawText(
            scr_width / 4,
            scr_height / 4,
            fieldNameFont,
            fieldNames[1],
            Graphics.TEXT_JUSTIFY_CENTER
          );
          dc.drawText(
            scr_width / 4,
            scr_height / 4 + fieldNameFontHeight,
            fieldValueFont,
            fieldValues[1],
            Graphics.TEXT_JUSTIFY_CENTER
          );

          dc.drawText(
            scr_width - scr_width / 4,
            scr_height / 4,
            fieldNameFont,
            fieldNames[2],
            Graphics.TEXT_JUSTIFY_CENTER
          );
          dc.drawText(
            scr_width - scr_width / 4,
            scr_height / 4 + fieldNameFontHeight,
            fieldValueFont,
            fieldValues[2],
            Graphics.TEXT_JUSTIFY_CENTER
          );

          dc.drawText(
            scr_width / 4,
            scr_height / 2 + gap,
            fieldNameFont,
            fieldNames[3],
            Graphics.TEXT_JUSTIFY_CENTER
          );
          dc.drawText(
            scr_width / 4,
            scr_height / 2 + gap + fieldNameFontHeight,
            fieldValueFont,
            fieldValues[3],
            Graphics.TEXT_JUSTIFY_CENTER
          );

          dc.drawText(
            scr_width - scr_width / 4,
            scr_height / 2 + gap,
            fieldNameFont,
            fieldNames[4],
            Graphics.TEXT_JUSTIFY_CENTER
          );
          dc.drawText(
            scr_width - scr_width / 4,
            scr_height / 2 + gap + fieldNameFontHeight,
            fieldValueFont,
            fieldValues[4],
            Graphics.TEXT_JUSTIFY_CENTER
          );

          dc.drawText(
            scr_width / 2,
            scr_height - gap - fieldNameFontHeight - fieldValueFontHeight,
            fieldNameFont,
            fieldNames[5],
            Graphics.TEXT_JUSTIFY_CENTER
          );

          dc.drawText(
            scr_width / 2,
            scr_height - gap - fieldValueFontHeight,
            fieldValueFont,
            fieldValues[5],
            Graphics.TEXT_JUSTIFY_CENTER
          );
        }
        // 8 fields layout
        if (fieldNB == 8) {
          var gap;
          var fieldNameFont = Graphics.FONT_XTINY;
          var fieldValueFont = nb_Font;
          var fieldNameFontHeight = Graphics.getFontHeight(fieldNameFont);
          var fieldValueFontHeight = Graphics.getFontHeight(fieldValueFont);
          if (scr_width < 260) {
            gap = dc.getWidth() / 80;
            fieldNameFontHeight = fieldNameFontHeight - 4;
          } else {
            gap = dc.getWidth() / 80;
          }
          dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
          dc.clear();
          drawBackground(dc);
          if (eucData.drawLines) {
            dc.setColor(eucData.linesColor, Graphics.COLOR_BLACK);
            dc.drawLine(
              gap,
              scr_height / 2.6,
              scr_width - gap,
              scr_height / 2.6
            );
            dc.drawLine(
              scr_width / 2,
              2 * gap + fieldValueFontHeight,
              scr_width / 2,
              scr_height / 2.6 - 2 * gap
            );
            dc.drawLine(
              scr_width / 2,
              scr_height / 2.6 + 2 * gap,
              scr_width / 2,
              scr_height / 1.6 - 2 * gap
            );
            dc.drawLine(
              gap,
              scr_height / 1.6,
              scr_width - gap,
              scr_height / 1.6
            );
            dc.drawLine(
              scr_width / 2,
              scr_height / 1.6 + 2 * gap,
              scr_width / 2,
              scr_height - (2 * gap + fieldValueFontHeight)
            );
          }
          if (eucData.paired == true) {
            dc.setColor(eucData.txtColor, Graphics.COLOR_TRANSPARENT);
          } else {
            dc.setColor(eucData.txtColor_unpr, Graphics.COLOR_TRANSPARENT);
          }

          //1st field doesn't have a name
          dc.drawText(
            scr_width / 2,
            gap,
            fieldValueFont,
            fieldValues[0],
            Graphics.TEXT_JUSTIFY_CENTER
          );

          dc.drawText(
            scr_width / 3.7,
            scr_height / 6.4,
            fieldNameFont,
            fieldNames[1],
            Graphics.TEXT_JUSTIFY_CENTER
          );
          dc.drawText(
            scr_width / 3.7,
            scr_height / 6.4 + fieldNameFontHeight,
            fieldValueFont,
            fieldValues[1],
            Graphics.TEXT_JUSTIFY_CENTER
          );

          dc.drawText(
            scr_width - scr_width / 3.7,
            scr_height / 6.4,
            fieldNameFont,
            fieldNames[2],
            Graphics.TEXT_JUSTIFY_CENTER
          );
          dc.drawText(
            scr_width - scr_width / 3.7,
            scr_height / 6.4 + fieldNameFontHeight,
            fieldValueFont,
            fieldValues[2],
            Graphics.TEXT_JUSTIFY_CENTER
          );

          dc.drawText(
            scr_width / 4.5,
            scr_height / 2.6 + gap,
            fieldNameFont,
            fieldNames[3],
            Graphics.TEXT_JUSTIFY_CENTER
          );
          dc.drawText(
            scr_width / 4.5,
            scr_height / 2.6 + gap + fieldNameFontHeight,
            fieldValueFont,
            fieldValues[3],
            Graphics.TEXT_JUSTIFY_CENTER
          );

          dc.drawText(
            scr_width - scr_width / 4.5,
            scr_height / 2.6 + gap,
            fieldNameFont,
            fieldNames[4],
            Graphics.TEXT_JUSTIFY_CENTER
          );
          dc.drawText(
            scr_width - scr_width / 4.5,
            scr_height / 2.6 + gap + fieldNameFontHeight,
            fieldValueFont,
            fieldValues[4],
            Graphics.TEXT_JUSTIFY_CENTER
          );

          //
          dc.drawText(
            scr_width / 3.7,
            scr_height / 1.6 + gap,
            fieldNameFont,
            fieldNames[5],
            Graphics.TEXT_JUSTIFY_CENTER
          );
          dc.drawText(
            scr_width / 3.7,
            scr_height / 1.6 + gap + fieldNameFontHeight,
            fieldValueFont,
            fieldValues[5],
            Graphics.TEXT_JUSTIFY_CENTER
          );

          dc.drawText(
            scr_width - scr_width / 3.7,
            scr_height / 1.6 + gap,
            fieldNameFont,
            fieldNames[6],
            Graphics.TEXT_JUSTIFY_CENTER
          );
          dc.drawText(
            scr_width - scr_width / 3.7,
            scr_height / 1.6 + gap + fieldNameFontHeight,
            fieldValueFont,
            fieldValues[6],
            Graphics.TEXT_JUSTIFY_CENTER
          );
          //

          dc.drawText(
            scr_width / 2,
            scr_height - gap - fieldValueFontHeight,
            fieldValueFont,
            fieldValues[7],
            Graphics.TEXT_JUSTIFY_CENTER
          );
        }
        if (!EUCAlarms.textAlert.equals("none")) {
          dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
          dc.fillRectangle(
            0,
            dc.getWidth() / 2 - Graphics.getFontHeight(Graphics.FONT_SMALL) / 2,
            dc.getWidth(),
            Graphics.getFontHeight(Graphics.FONT_SMALL)
          );
          dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
          dc.drawLine(
            0,
            dc.getHeight() / 2 -
              Graphics.getFontHeight(Graphics.FONT_SMALL) / 2 -
              1,
            dc.getWidth(),
            dc.getHeight() / 2 -
              Graphics.getFontHeight(Graphics.FONT_SMALL) / 2 -
              1
          );
          dc.drawLine(
            0,
            dc.getHeight() / 2 +
              Graphics.getFontHeight(Graphics.FONT_SMALL) / 2 +
              1,
            dc.getWidth(),
            dc.getHeight() / 2 +
              Graphics.getFontHeight(Graphics.FONT_SMALL) / 2 +
              1
          );
          dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
          dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2 -
              Graphics.getFontHeight(Graphics.FONT_SMALL) / 2,
            Graphics.FONT_SMALL,
            EUCAlarms.textAlert,
            Graphics.TEXT_JUSTIFY_CENTER
          );
        }

        if (eucData.displayWind == true && Position.getInfo().accuracy >= 2) {
          renderWindOnUI(scr_width, dc);
        }
        if (eucData.displayNorth == true && Position.getInfo().accuracy >= 2) {
          renderNorthOnUI(scr_width, dc);
        }
      }
    }
  }
  /*
    if (eucData.GUI == true) {
      View.onUpdate(dc);
    }
    
}*/
  function renderNorthOnUI(screenDiam, dc) {
    var rawNorth = Position.getInfo().heading;
    if (rawNorth != null) {
      var north = rawNorth * -57.2958;
      var ratio = 454.0 / screenDiam;

      var arrow_width = (screenDiam * ratio) / 110;

      var arrow_heigth = screenDiam / 2 - screenDiam / 20;
      var arrow_heigth2 = screenDiam / 2 - screenDiam / 25;

      var x1 = getXY(screenDiam, 0, screenDiam / 2 - 1, north, 1);
      var x2 = getXY(screenDiam, 0, arrow_heigth, north - arrow_width, 1);
      var x3 = getXY(screenDiam, 0, arrow_heigth2, north, 1);
      var x4 = getXY(screenDiam, 0, arrow_heigth, north + arrow_width, 1);
      //var ptsStroke = [x1, x2, x3];
      var ptsFill = [x1, x2, x3, x4];
      dc.setColor(0xd53420, Graphics.COLOR_TRANSPARENT);
      /*  dc.setPenWidth(1);
      dc.drawLine(
        ptsStroke[0][0],
        ptsStroke[0][1],
        ptsStroke[1][0],
        ptsStroke[1][1]
      );
      dc.drawLine(
        ptsStroke[1][0],
        ptsStroke[1][1],
        ptsStroke[2][0],
        ptsStroke[2][1]
      );
      dc.drawLine(
        ptsStroke[2][0],
        ptsStroke[2][1],
        ptsStroke[0][0],
        ptsStroke[0][1]
      );*/
      dc.fillPolygon(ptsFill);
    }
  }

  function renderWindOnUI(screenDiam, dc) {
    var wx = Weather.getCurrentConditions();
    if (wx != null) {
      var windBearing = Weather.getCurrentConditions().windBearing;
      var rawNorth = Toybox.Position.getInfo().heading;

      if (rawNorth != null && windBearing != null) {
        var north = rawNorth * -57.2958;
        var wind = windBearing + north;

        var ratio = 454.0 / screenDiam;
        var arrow_width = (screenDiam * ratio) / 110;
        var arrow_heigth = screenDiam / 2 - screenDiam / 20;
        var arrow_heigth2 = screenDiam / 2 - screenDiam / 25;

        var x1 = getXY(screenDiam, 0, screenDiam / 2 - 1, wind, 1);
        var x2 = getXY(screenDiam, 0, arrow_heigth, wind - arrow_width, 1);
        var x3 = getXY(screenDiam, 0, arrow_heigth2, wind, 1);
        var x4 = getXY(screenDiam, 0, arrow_heigth, wind + arrow_width, 1);
        //var ptsStroke = [x1, x3, x4];
        var ptsFill = [x1, x2, x3, x4];
        dc.setColor(0x0077b6, Graphics.COLOR_TRANSPARENT);
        /* dc.setPenWidth(1);
      dc.drawLine(
        ptsStroke[0][0],
        ptsStroke[0][1],
        ptsStroke[1][0],
        ptsStroke[1][1]
      );
      dc.drawLine(
        ptsStroke[1][0],
        ptsStroke[1][1],
        ptsStroke[2][0],
        ptsStroke[2][1]
      );
      dc.drawLine(
        ptsStroke[2][0],
        ptsStroke[2][1],
        ptsStroke[0][0],
        ptsStroke[0][1]
      );*/
        dc.fillPolygon(ptsFill);
      }
    }
  }
  function drawBackground(dc) {
    if (fill_logo != null) {
      //dc.setColor(eucData.logoColor, Graphics.COLOR_TRANSPARENT);
      dc.setColor(eucData.logoColor, Graphics.COLOR_TRANSPARENT);

      for (var i = 0; i < fill_logo.size(); i++) {
        dc.fillPolygon(fill_logo[i]);
      }
    }
    if (empty_logo != null) {
      dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
      for (var i = 0; i < empty_logo.size(); i++) {
        dc.fillPolygon(empty_logo[i]);
      }
    }
  }
  function loadStoredValues() {
    if (Storage.getValue("maxTemp") != null) {
      maxTemp = Storage.getValue("maxTemp");
    }
    if (Storage.getValue("minTemp") != null) {
      minTemp = Storage.getValue("minTemp");
    }
    if (Storage.getValue("maxVoltage") != null) {
      maxVoltage = Storage.getValue("maxVoltage");
    }
    if (Storage.getValue("minVoltage") != null) {
      minVoltage = Storage.getValue("minVoltage");
    }
    if (Storage.getValue("maxBatteryPerc") != null) {
      maxBatteryPerc = Storage.getValue("maxBatteryPerc");
    }
    if (Storage.getValue("minBatteryPerc") != null) {
      minBatteryPerc = Storage.getValue("minBatteryPerc");
    }
    if (Storage.getValue("sessionDistance") != null) {
      sessionDistance = Storage.getValue("sessionDistance");
    }
    if (Storage.getValue("avgSpeed") != null) {
      avgSpeed = Storage.getValue("avgSpeed");
    }
    if (Storage.getValue("maxPWM") != null) {
      maxPWM = Storage.getValue("maxPWM");
    }
    if (Storage.getValue("movingmsec") != null) {
      movingmsec = Storage.getValue("movingmsec");
    }
    if (Storage.getValue("avgCurrent") != null) {
    }
    if (Storage.getValue("avgPower") != null) {
      avgPower = Storage.getValue("avgPower");
    }
    if (Storage.getValue("maxSpeed") != null) {
      maxSpeed = Storage.getValue("maxSpeed");
    }
    if (Storage.getValue("maxPower") != null) {
      maxPower = Storage.getValue("maxPower");
    }
    if (Storage.getValue("maxCurrent") != null) {
      maxCurrent = Storage.getValue("maxCurrent");
    }
    if (Storage.getValue("sumCurrent") != null) {
      sumCurrent = Storage.getValue("sumCurrent");
    }
    if (Storage.getValue("sumPower") != null) {
      sumPower = Storage.getValue("sumPower");
    }
    if (Storage.getValue("callNb") != null) {
      callNb = Storage.getValue("callNb");
    }
    if (Storage.getValue("startingEUCTripDistance") != null) {
      startingEUCTripDistance = Storage.getValue("startingEUCTripDistance");
    }
    if (Storage.getValue("EUCBatteryPercStart") != null) {
      EUCBatteryPercStart = Storage.getValue("EUCBatteryPercStart");
    }

    if (eucData.useRadar == true) {
      if (Storage.getValue("totalVehCount") == null) {
        eucData.totalVehCount = 0;
      } else {
        eucData.totalVehCount = Storage.getValue("totalVehCount");
      }
    }

    // should only be required for max values
    mMaxSpeedField.setData(maxSpeed);
    mMaxPWMField.setData(maxPWM);
    mMaxTempField.setData(maxTemp);
    //mMinVoltageField.setData(minVoltage);
    //mMaxVoltageField.setData(maxVoltage);
    mMinBatteryField.setData(minBatteryPerc);
  }

  function onTimerReset() {
    //System.println("reset");
    //Storage.clearValues();
  }
  function onTimerStop() {
    // System.println("stop");
    Storage.setValue("maxTemp", maxTemp);
    Storage.setValue("minTemp", minTemp);
    Storage.setValue("maxVoltage", maxVoltage);
    Storage.setValue("minVoltage", minVoltage);
    Storage.setValue("maxBatteryPerc", maxBatteryPerc);
    Storage.setValue("minBatteryPerc", minBatteryPerc);
    Storage.setValue("sessionDistance", sessionDistance);
    Storage.setValue("avgSpeed", avgSpeed);
    Storage.setValue("avgCurrent", avgCurrent);
    Storage.setValue("avgPower", avgPower);
    Storage.setValue("maxSpeed", maxSpeed);
    Storage.setValue("maxPWM", maxPWM);
    Storage.setValue("maxCurrent", maxCurrent);
    Storage.setValue("maxPower", maxPower);
    Storage.setValue("sumCurrent", sumCurrent);
    Storage.setValue("sumPower", sumPower);
    Storage.setValue("callNb", callNb);
    Storage.setValue("movingmsec", movingmsec);
    Storage.setValue("startingEUCTripDistance", startingEUCTripDistance);
    Storage.setValue("EUCBatteryPercStart", EUCBatteryPercStart);
    if (eucData.useRadar == true) {
      Storage.setValue("totalVehCount", eucData.totalVehCount);
    }
  }
}
