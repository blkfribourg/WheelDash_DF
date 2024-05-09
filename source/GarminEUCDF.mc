import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;
using Toybox.Math;
import Toybox.System;
import Toybox.Position;
using Toybox.Application.Storage;
class GarminEUCDF extends WatchUi.DataField {
  var fill_logo;
  var empty_logo;
  var delay = 3;
  var firstCall = true;
  var bleDelegate;
  var IM_count = 0;
  hidden var field1 = "NC";
  hidden var field2 = "NC";
  hidden var field3 = "NC";
  hidden var field4 = "NC";
  hidden var field5 = "NC";
  hidden var field6 = "NC";
  hidden var field1_value = 0;
  hidden var field2_value = 0;
  hidden var field3_value = 0;
  hidden var field4_value = 0;
  hidden var field5_value = 0;
  hidden var field6_value = 0;
  const SPEED_FIELD_ID = 0;
  const PWM_FIELD_ID = 1;
  const VOLTAGE_FIELD_ID = 2;
  //const CURRENT_FIELD_ID = 3;
  //const POWER_FIELD_ID = 4;
  const TEMP_FIELD_ID = 5;
  const TRIPDISTANCE_FIELD_ID = 6;
  const MAXSPEED_FIELD_ID = 7;
  const MAXPWM_FIELD_ID = 8;
  const MAXCURRENT_FIELD_ID = 9;
  const MAXPOWER_FIELD_ID = 10;
  const MAXTEMP_FIELD_ID = 11;
  const AVGSPEED_FIELD_ID = 12;
  const AVGCURRENT_FIELD_ID = 13;
  const AVGPOWER_FIELD_ID = 14;

  const MINVOLTAGE_FIELD_ID = 16;
  const MAXVOLTAGE_FIELD_ID = 17;
  const MINBATTERY_FIELD_ID = 18;
  // const MAXBATTERY_FIELD_ID = 19;
  // const MINTEMP_FIELD_ID = 20;
  const EORBATTERY_FIELD_ID = 21;
  /*
  const SPEED_FIELD_ID_MILES = 22;
  const TEMP_F_FIELD_ID = 23;
  const TRIPDISTANCE_FIELD_ID_MILES = 24;
  const MAXSPEED_FIELD_ID_MILES = 25;
  const MAXTEMP_F_FIELD_ID = 26;
  const AVGSPEED_FIELD_ID_MILES = 27;
  */
  var mSpeedField = null;
  var mPWMField = null;
  var mVoltageField = null;
  var mCurrentField = null;
  var mPowerField = null;
  var mTempField = null;
  var mTripDistField = null;
  var mMaxSpeedField = null;
  var mMaxPWMField = null;
  var mMaxCurrentField = null;
  var mMaxPowerField = null;
  var mMaxTempField = null;
  var mMinTempField = null;
  var mAvgSpeedField = null;
  var mAvgCurrentField = null;
  var mAvgPowerField = null;
  var mMinVoltageField = null;
  var mMaxVoltageField = null;
  var mMinBatteryField = null;
  var mMaxBatteryField = null;
  var mEORBatteryField = null;
  var _alertDisplayed = false;
  var nb_Font;
  // private var cDrawables = {};

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
    _maxPWM
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
    // startingMoment = _startingMoment;
  }
  function fieldsInitialize() {
    /*
    if (eucData.useMiles == true) {
      mSpeedField = createField(
        "speed",
        SPEED_FIELD_ID_MILES,
        FitContributor.DATA_TYPE_FLOAT,
        { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "mph" }
      );

      mTripDistField = createField(
        "TripDistance",
        TRIPDISTANCE_FIELD_ID_MILES,
        FitContributor.DATA_TYPE_FLOAT,
        { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "miles" }
      );
      mMaxSpeedField = createField(
        "Max_speed",
        MAXSPEED_FIELD_ID_MILES,
        FitContributor.DATA_TYPE_FLOAT,
        { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "mph" }
      );

      mAvgSpeedField = createField(
        "Avg_Speed",
        AVGSPEED_FIELD_ID_MILES,
        FitContributor.DATA_TYPE_FLOAT,
        { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "mph" }
      );
    } else {
      */
    mSpeedField = createField(
      "speed",
      SPEED_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "km/h" }
    );

    mTripDistField = createField(
      "TripDistance",
      TRIPDISTANCE_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "km" }
    );
    mMaxSpeedField = createField(
      "Max_speed",
      MAXSPEED_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "km/h" }
    );

    mAvgSpeedField = createField(
      "Avg_Speed",
      AVGSPEED_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "km/h" }
    );
    /*
    }
   
    if (eucData.useFahrenheit == true) {
      mMaxTempField = createField(
        "Max_Temp",
        MAXTEMP_F_FIELD_ID,
        FitContributor.DATA_TYPE_FLOAT,
        { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "°F" }
      );
      mTempField = createField(
        "Temperature",
        TEMP_F_FIELD_ID,
        FitContributor.DATA_TYPE_FLOAT,
        { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "°F" }
      );
    } else {
      */
    mMaxTempField = createField(
      "Max_Temp",
      MAXTEMP_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "°C" }
    );
    mTempField = createField(
      "Temperature",
      TEMP_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "°C" }
    );
    //}
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

    mMaxPWMField = createField(
      "Max_PWM",
      MAXPWM_FIELD_ID,
      FitContributor.DATA_TYPE_UINT8,
      { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "%" }
    );

    mMinVoltageField = createField(
      "Min_Voltage",
      MINVOLTAGE_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "V" }
    );
    mMaxVoltageField = createField(
      "Max_Voltage",
      MAXVOLTAGE_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "V" }
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

    // set fields to 0

    // V0.0.38
    mSpeedField.setData(0.0);
    mPWMField.setData(0.0);
    mVoltageField.setData(0.0);
    mTempField.setData(0.0);
    mTripDistField.setData(0.0);
    mMaxSpeedField.setData(0.0);
    mMaxPWMField.setData(0.0);
    mMaxTempField.setData(0.0);
    mAvgSpeedField.setData(0.0);
    mMinVoltageField.setData(0.0);
    mMaxVoltageField.setData(0.0);
    //  mMaxBatteryField.setData(0.0);
    mMinBatteryField.setData(0.0);
    //mMinTempField.setData(0.0);
  }

  var maxSpeed = 0.0;
  var maxPWM = 0.0;
  var maxCurrent = 0.0;
  var maxPower = 0.0;
  var maxTemp = -255.0;
  var minTemp = 255.0;
  var currentPWM = 0.0;
  var correctedSpeed = 0.0;
  var correctedTotalDistance = 0.0;
  var displayedTemperature = 0.0;
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
  var avgMovingSpeed = 0.0;

  function updateFitData(garminInfo) {
    callNb++;
    currentVoltage = eucData.getVoltage();
    currentBatteryPerc = eucData.getBatteryPercentage();
    currentPWM = eucData.getPWM();
    correctedSpeed = eucData.getCorrectedSpeed();
    displayedTemperature = eucData.getTemperature();
    correctedTotalDistance = eucData.getCorrectedTotalDistance();
    currentCurrent = eucData.getCurrent();
    currentPower = currentCurrent * currentVoltage;

    mSpeedField.setData(correctedSpeed); // id 0
    mPWMField.setData(currentPWM); //id 1
    mVoltageField.setData(currentVoltage); // id 2
    //    mCurrentField.setData(currentCurrent); // id 3
    //    mPowerField.setData(currentPower); // id 4
    mTempField.setData(displayedTemperature); // id 5
    if (currentBatteryPerc > 0 && eucData.paired == true) {
      mEORBatteryField.setData(currentBatteryPerc);
    }
    if (correctedSpeed > maxSpeed) {
      maxSpeed = correctedSpeed;
      mMaxSpeedField.setData(maxSpeed); // id 7
    }
    if (currentPWM > maxPWM) {
      maxPWM = currentPWM;
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

    if (displayedTemperature > maxTemp) {
      maxTemp = displayedTemperature;
      mMaxTempField.setData(maxTemp); // id 11
    }
    if (displayedTemperature < minTemp && eucData.temperature != 0.0) {
      minTemp = displayedTemperature;
      // mMinTempField.setData(minTemp); // id 11
    }
    if (currentVoltage > maxVoltage && currentVoltage != 0.0) {
      maxVoltage = currentVoltage;
      mMaxVoltageField.setData(maxVoltage);
    }
    if (currentVoltage < minVoltage && currentVoltage != 0.0) {
      minVoltage = currentVoltage;
      mMinVoltageField.setData(minVoltage);
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
        startingEUCTripDistance = correctedTotalDistance;
      }
      sessionDistance = correctedTotalDistance - startingEUCTripDistance;
      //avgSpeed = sessionDistance / (elapsedTime.value() / 3600.0);
      avgSpeed = sessionDistance / (elapsedTime / 3600.0);

      var minimalMovingSpeed = 2.5;

      if (eucData.correctedSpeed > minimalMovingSpeed && movingmsec != 0) {
        movingmsec = movingmsec + 1000.0; //Assuming refresh exactly every 1000ms, which is not true as far as I know
        avgMovingSpeed = sessionDistance / (movingmsec / 3600000.0);
      }
    } else {
      movingmsec = 0.0;
      sessionDistance = 0.0;
      avgSpeed = 0.0;
    }
    mTripDistField.setData(sessionDistance); // id 6

    mAvgSpeedField.setData(avgSpeed); // id 12

    sumCurrent = sumCurrent + currentCurrent;
    sumPower = sumPower + currentPower;
    avgCurrent = sumCurrent / callNb;
    avgPower = sumPower / callNb;
    //mAvgCurrentField.setData(sumCurrent / callNb); // id 13
    //mAvgPowerField.setData(sumPower / callNb); // id 14
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
    currentPWM = 0.0;
    correctedSpeed = 0.0;
    correctedTotalDistance = 0.0;
    displayedTemperature = 0.0;
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
    avgMovingSpeed = 0.0;
    avgCurrent = 0.0;
    avgPower = 0.0;
  }
  function getFieldValues() {
    if (AppStorage.getSetting("field1") == 0) {
      field1 = "SPEED";
      field1_value = valueRound(correctedSpeed, "%.1f");
    }
    if (AppStorage.getSetting("field1") == 1) {
      field1 = "VOLTAGE";
      field1_value = valueRound(currentVoltage, "%.1f");
    }
    if (AppStorage.getSetting("field1") == 2) {
      field1 = "TRP DIST";
      field1_value = valueRound(sessionDistance, "%.1f");
    }
    if (AppStorage.getSetting("field1") == 3) {
      field1 = "CURR";
      field1_value = valueRound(currentCurrent, "%.1f");
    }
    if (AppStorage.getSetting("field1") == 4) {
      field1 = "TEMP";
      field1_value = valueRound(displayedTemperature, "%.1f");
    }
    if (AppStorage.getSetting("field1") == 5) {
      field1 = "TT DIST";
      field1_value = valueRound(correctedTotalDistance, "%.1f");
    }
    if (AppStorage.getSetting("field1") == 6) {
      field1 = "PWM";
      field1_value = valueRound(currentPWM, "%.1f");
    }
    if (AppStorage.getSetting("field1") == 7) {
      field1 = "BATT %";
      field1_value = valueRound(currentBatteryPerc, "%.1f");
    }
    if (AppStorage.getSetting("field1") == 8) {
      field1 = "MIN TEMP";
      field1_value = valueRound(minTemp, "%.1f");
    }
    if (AppStorage.getSetting("field1") == 9) {
      field1 = "MAX TEMP";
      field1_value = valueRound(maxTemp, "%.1f");
    }
    if (AppStorage.getSetting("field1") == 10) {
      field1 = "MAX SPD";
      field1_value = valueRound(maxSpeed, "%.1f");
    }
    if (AppStorage.getSetting("field1") == 11) {
      field1 = "AVG SPD";
      field1_value = valueRound(avgSpeed, "%.1f");
    }
    if (AppStorage.getSetting("field1") == 12) {
      field1 = "MIN VOLT";
      field1_value = valueRound(minVoltage, "%.1f");
    }
    if (AppStorage.getSetting("field1") == 13) {
      field1 = "MAX VOLT";
      field1_value = valueRound(maxVoltage, "%.1f");
    }
    if (AppStorage.getSetting("field1") == 14) {
      field1 = "MAX CURR";
      field1_value = valueRound(maxCurrent, "%.1f");
    }
    if (AppStorage.getSetting("field1") == 15) {
      field1 = "AVG CURR";
      field1_value = valueRound(avgCurrent, "%.1f");
    }
    if (AppStorage.getSetting("field1") == 16) {
      field1 = "MIN BATT %";
      field1_value = valueRound(minBatteryPerc, "%.1f");
    }
    if (AppStorage.getSetting("field1") == 17) {
      field1 = "MAX BATT %";
      field1_value = valueRound(maxBatteryPerc, "%.1f");
    }
    if (AppStorage.getSetting("field1") == 18) {
      field1 = "AVG PWR";
      field1_value = valueRound(avgPower, "%.1f");
    }
    if (AppStorage.getSetting("field1") == 19) {
      field1 = "MAX PWR %";
      field1_value = valueRound(maxPower, "%.1f");
    }

    if (AppStorage.getSetting("field2") == 0) {
      field2 = "SPEED";
      field2_value = valueRound(correctedSpeed, "%.1f");
    }
    if (AppStorage.getSetting("field2") == 1) {
      field2 = "VOLTAGE";
      field2_value = valueRound(currentVoltage, "%.1f");
    }
    if (AppStorage.getSetting("field2") == 2) {
      field2 = "TRP DIST";
      field2_value = valueRound(sessionDistance, "%.1f");
    }
    if (AppStorage.getSetting("field2") == 3) {
      field2 = "CURR";
      field2_value = valueRound(currentCurrent, "%.1f");
    }
    if (AppStorage.getSetting("field2") == 4) {
      field2 = "TEMP";
      field2_value = valueRound(displayedTemperature, "%.1f");
    }
    if (AppStorage.getSetting("field2") == 5) {
      field2 = "TT DIST";
      field2_value = valueRound(correctedTotalDistance, "%.1f");
    }
    if (AppStorage.getSetting("field2") == 6) {
      field2 = "PWM";
      field2_value = valueRound(currentPWM, "%.1f");
    }
    if (AppStorage.getSetting("field2") == 7) {
      field2 = "BATT %";
      field2_value = valueRound(currentBatteryPerc, "%.1f");
    }
    if (AppStorage.getSetting("field2") == 8) {
      field2 = "MIN TEMP";
      field2_value = valueRound(minTemp, "%.1f");
    }
    if (AppStorage.getSetting("field2") == 9) {
      field2 = "MAX TEMP";
      field2_value = valueRound(maxTemp, "%.1f");
    }
    if (AppStorage.getSetting("field2") == 10) {
      field2 = "MAX SPD";
      field2_value = valueRound(maxSpeed, "%.1f");
    }
    if (AppStorage.getSetting("field2") == 11) {
      field2 = "AVG SPD";
      field2_value = valueRound(avgSpeed, "%.1f");
    }
    if (AppStorage.getSetting("field2") == 12) {
      field2 = "MIN VOLT";
      field2_value = valueRound(minVoltage, "%.1f");
    }
    if (AppStorage.getSetting("field2") == 13) {
      field2 = "MAX VOLT";
      field2_value = valueRound(maxVoltage, "%.1f");
    }
    if (AppStorage.getSetting("field2") == 14) {
      field2 = "MAX CURR";
      field2_value = valueRound(maxCurrent, "%.1f");
    }
    if (AppStorage.getSetting("field2") == 15) {
      field2 = "MAX CURR";
      field2_value = valueRound(avgCurrent, "%.1f");
    }
    if (AppStorage.getSetting("field2") == 16) {
      field2 = "MIN BATT %";
      field2_value = valueRound(minBatteryPerc, "%.1f");
    }
    if (AppStorage.getSetting("field2") == 17) {
      field2 = "MAX BATT %";
      field2_value = valueRound(maxBatteryPerc, "%.1f");
    }
    if (AppStorage.getSetting("field2") == 18) {
      field2 = "AVG PWR";
      field2_value = valueRound(avgPower, "%.1f");
    }
    if (AppStorage.getSetting("field2") == 19) {
      field2 = "MAX PWR";
      field2_value = valueRound(maxPower, "%.1f");
    }

    if (AppStorage.getSetting("field3") == 0) {
      field3 = "SPEED";
      field3_value = valueRound(correctedSpeed, "%.1f");
    }
    if (AppStorage.getSetting("field3") == 1) {
      field3 = "VOLTAGE";
      field3_value = valueRound(currentVoltage, "%.1f");
    }
    if (AppStorage.getSetting("field3") == 2) {
      field3 = "TRP DIST";
      field3_value = valueRound(sessionDistance, "%.1f");
    }
    if (AppStorage.getSetting("field3") == 3) {
      field3 = "CURR";
      field3_value = valueRound(currentCurrent, "%.1f");
    }
    if (AppStorage.getSetting("field3") == 4) {
      field3 = "TEMP";
      field3_value = valueRound(displayedTemperature, "%.1f");
    }
    if (AppStorage.getSetting("field3") == 5) {
      field3 = "TT DIST";
      field3_value = valueRound(correctedTotalDistance, "%.1f");
    }
    if (AppStorage.getSetting("field3") == 6) {
      field3 = "PWM";
      field3_value = valueRound(currentPWM, "%.1f");
    }
    if (AppStorage.getSetting("field3") == 7) {
      field3 = "BATT %";
      field3_value = valueRound(currentBatteryPerc, "%.1f");
    }
    if (AppStorage.getSetting("field3") == 8) {
      field3 = "MIN TEMP";
      field3_value = valueRound(minTemp, "%.1f");
    }
    if (AppStorage.getSetting("field3") == 9) {
      field3 = "MAX TEMP";
      field3_value = valueRound(maxTemp, "%.1f");
    }
    if (AppStorage.getSetting("field3") == 10) {
      field3 = "MAX SPD";
      field3_value = valueRound(maxSpeed, "%.1f");
    }
    if (AppStorage.getSetting("field3") == 11) {
      field3 = "AVG SPD";
      field3_value = valueRound(avgSpeed, "%.1f");
    }
    if (AppStorage.getSetting("field3") == 12) {
      field3 = "MIN VOLT";
      field3_value = valueRound(minVoltage, "%.1f");
    }
    if (AppStorage.getSetting("field3") == 13) {
      field3 = "MAX VOLT";
      field3_value = valueRound(maxVoltage, "%.1f");
    }
    if (AppStorage.getSetting("field3") == 14) {
      field3 = "MAX CURR";
      field3_value = valueRound(maxCurrent, "%.1f");
    }
    if (AppStorage.getSetting("field3") == 15) {
      field3 = "MAX CURR";
      field3_value = valueRound(avgCurrent, "%.1f");
    }
    if (AppStorage.getSetting("field3") == 16) {
      field3 = "MIN BATT %";
      field3_value = valueRound(minBatteryPerc, "%.1f");
    }
    if (AppStorage.getSetting("field3") == 17) {
      field3 = "MAX BATT %";
      field3_value = valueRound(maxBatteryPerc, "%.1f");
    }
    if (AppStorage.getSetting("field3") == 18) {
      field3 = "AVG PWR";
      field3_value = valueRound(avgPower, "%.1f");
    }
    if (AppStorage.getSetting("field3") == 19) {
      field3 = "MAX PWR %";
      field3_value = valueRound(maxPower, "%.1f");
    }

    if (AppStorage.getSetting("field4") == 0) {
      field4 = "SPEED";
      field4_value = valueRound(correctedSpeed, "%.1f");
    }
    if (AppStorage.getSetting("field4") == 1) {
      field4 = "VOLTAGE";
      field4_value = valueRound(currentVoltage, "%.1f");
    }
    if (AppStorage.getSetting("field4") == 2) {
      field4 = "TRP DIST";
      field4_value = valueRound(sessionDistance, "%.1f");
    }
    if (AppStorage.getSetting("field4") == 3) {
      field4 = "CURR";
      field4_value = valueRound(currentCurrent, "%.1f");
    }
    if (AppStorage.getSetting("field4") == 4) {
      field4 = "TEMP";
      field4_value = valueRound(displayedTemperature, "%.1f");
    }
    if (AppStorage.getSetting("field4") == 5) {
      field4 = "TT DIST";
      field4_value = valueRound(correctedTotalDistance, "%.1f");
    }
    if (AppStorage.getSetting("field4") == 6) {
      field4 = "PWM";
      field4_value = valueRound(currentPWM, "%.1f");
    }
    if (AppStorage.getSetting("field4") == 7) {
      field4 = "BATT %";
      field4_value = valueRound(currentBatteryPerc, "%.1f");
    }
    if (AppStorage.getSetting("field4") == 8) {
      field4 = "MIN TEMP";
      field4_value = valueRound(minTemp, "%.1f");
    }
    if (AppStorage.getSetting("field4") == 9) {
      field4 = "MAX TEMP";
      field4_value = valueRound(maxTemp, "%.1f");
    }
    if (AppStorage.getSetting("field4") == 10) {
      field4 = "MAX SPD";
      field4_value = valueRound(maxSpeed, "%.1f");
    }
    if (AppStorage.getSetting("field4") == 11) {
      field4 = "AVG SPD";
      field4_value = valueRound(avgSpeed, "%.1f");
    }
    if (AppStorage.getSetting("field4") == 12) {
      field4 = "MIN VOLT";
      field4_value = valueRound(minVoltage, "%.1f");
    }
    if (AppStorage.getSetting("field4") == 13) {
      field4 = "MAX VOLT";
      field4_value = valueRound(maxVoltage, "%.1f");
    }
    if (AppStorage.getSetting("field4") == 14) {
      field4 = "MAX CURR";
      field4_value = valueRound(maxCurrent, "%.1f");
    }
    if (AppStorage.getSetting("field4") == 15) {
      field4 = "MAX CURR";
      field4_value = valueRound(avgCurrent, "%.1f");
    }
    if (AppStorage.getSetting("field4") == 16) {
      field4 = "MIN BATT %";
      field4_value = valueRound(minBatteryPerc, "%.1f");
    }
    if (AppStorage.getSetting("field4") == 17) {
      field4 = "MAX BATT %";
      field4_value = valueRound(maxBatteryPerc, "%.1f");
    }
    if (AppStorage.getSetting("field4") == 18) {
      field4 = "AVG PWR";
      field4_value = valueRound(avgPower, "%.1f");
    }
    if (AppStorage.getSetting("field4") == 19) {
      field4 = "MAX PWR %";
      field4_value = valueRound(maxPower, "%.1f");
    }

    if (AppStorage.getSetting("field5") == 0) {
      field5 = "SPEED";
      field5_value = valueRound(correctedSpeed, "%.1f");
    }
    if (AppStorage.getSetting("field5") == 1) {
      field5 = "VOLTAGE";
      field5_value = valueRound(currentVoltage, "%.1f");
    }
    if (AppStorage.getSetting("field5") == 2) {
      field5 = "TRP DIST";
      field5_value = valueRound(sessionDistance, "%.1f");
    }
    if (AppStorage.getSetting("field5") == 3) {
      field5 = "CURR";
      field5_value = valueRound(currentCurrent, "%.1f");
    }
    if (AppStorage.getSetting("field5") == 4) {
      field5 = "TEMP";
      field5_value = valueRound(displayedTemperature, "%.1f");
    }
    if (AppStorage.getSetting("field5") == 5) {
      field5 = "TT DIST";
      field5_value = valueRound(correctedTotalDistance, "%.1f");
    }
    if (AppStorage.getSetting("field5") == 6) {
      field5 = "PWM";
      field5_value = valueRound(currentPWM, "%.1f");
    }
    if (AppStorage.getSetting("field5") == 7) {
      field5 = "BATT %";
      field5_value = valueRound(currentBatteryPerc, "%.1f");
    }
    if (AppStorage.getSetting("field5") == 8) {
      field5 = "MIN TEMP";
      field5_value = valueRound(minTemp, "%.1f");
    }
    if (AppStorage.getSetting("field5") == 9) {
      field5 = "MAX TEMP";
      field5_value = valueRound(maxTemp, "%.1f");
    }
    if (AppStorage.getSetting("field5") == 10) {
      field5 = "MAX SPD";
      field5_value = valueRound(maxSpeed, "%.1f");
    }
    if (AppStorage.getSetting("field5") == 11) {
      field5 = "AVG SPD";
      field5_value = valueRound(avgSpeed, "%.1f");
    }
    if (AppStorage.getSetting("field5") == 12) {
      field5 = "MIN VOLT";
      field5_value = valueRound(minVoltage, "%.1f");
    }
    if (AppStorage.getSetting("field5") == 13) {
      field5 = "MAX VOLT";
      field5_value = valueRound(maxVoltage, "%.1f");
    }
    if (AppStorage.getSetting("field5") == 14) {
      field5 = "MAX CURR";
      field5_value = valueRound(maxCurrent, "%.1f");
    }
    if (AppStorage.getSetting("field5") == 15) {
      field5 = "MAX CURR";
      field5_value = valueRound(avgCurrent, "%.1f");
    }
    if (AppStorage.getSetting("field5") == 16) {
      field5 = "MIN BATT %";
      field5_value = valueRound(minBatteryPerc, "%.1f");
    }
    if (AppStorage.getSetting("field5") == 17) {
      field5 = "MAX BATT %";
      field5_value = valueRound(maxBatteryPerc, "%.1f");
    }
    if (AppStorage.getSetting("field5") == 18) {
      field5 = "AVG PWR";
      field5_value = valueRound(avgPower, "%.1f");
    }
    if (AppStorage.getSetting("field5") == 19) {
      field5 = "MAX PWR %";
      field5_value = valueRound(maxPower, "%.1f");
    }

    if (AppStorage.getSetting("field6") == 0) {
      field6 = "SPEED";
      field6_value = valueRound(correctedSpeed, "%.1f");
    }
    if (AppStorage.getSetting("field6") == 1) {
      field6 = "VOLTAGE";
      field6_value = valueRound(currentVoltage, "%.1f");
    }
    if (AppStorage.getSetting("field6") == 2) {
      field6 = "TRP DIST";
      field6_value = valueRound(sessionDistance, "%.1f");
    }
    if (AppStorage.getSetting("field6") == 3) {
      field6 = "CURR";
      field6_value = valueRound(currentCurrent, "%.1f");
    }
    if (AppStorage.getSetting("field6") == 4) {
      field6 = "TEMP";
      field6_value = valueRound(displayedTemperature, "%.1f");
    }
    if (AppStorage.getSetting("field6") == 5) {
      field6 = "TT DIST";
      field6_value = valueRound(correctedTotalDistance, "%.1f");
    }
    if (AppStorage.getSetting("field6") == 6) {
      field6 = "PWM";
      field6_value = valueRound(currentPWM, "%.1f");
    }
    if (AppStorage.getSetting("field6") == 7) {
      field6 = "BATT %";
      field6_value = valueRound(currentBatteryPerc, "%.1f");
    }
    if (AppStorage.getSetting("field6") == 8) {
      field6 = "MIN TEMP";
      field6_value = valueRound(minTemp, "%.1f");
    }
    if (AppStorage.getSetting("field6") == 9) {
      field6 = "MAX TEMP";
      field6_value = valueRound(maxTemp, "%.1f");
    }
    if (AppStorage.getSetting("field6") == 10) {
      field6 = "MAX SPD";
      field6_value = valueRound(maxSpeed, "%.1f");
    }
    if (AppStorage.getSetting("field6") == 11) {
      field6 = "AVG SPD";
      field6_value = valueRound(avgSpeed, "%.1f");
    }
    if (AppStorage.getSetting("field6") == 12) {
      field6 = "MIN VOLT";
      field6_value = valueRound(minVoltage, "%.1f");
    }
    if (AppStorage.getSetting("field6") == 13) {
      field6 = "MAX VOLT";
      field6_value = valueRound(maxVoltage, "%.1f");
    }
    if (AppStorage.getSetting("field6") == 14) {
      field6 = "MAX CURR";
      field6_value = valueRound(maxCurrent, "%.1f");
    }
    if (AppStorage.getSetting("field6") == 15) {
      field6 = "MAX CURR";
      field6_value = valueRound(avgCurrent, "%.1f");
    }
    if (AppStorage.getSetting("field6") == 16) {
      field6 = "MIN BATT %";
      field6_value = valueRound(minBatteryPerc, "%.1f");
    }
    if (AppStorage.getSetting("field6") == 17) {
      field6 = "MAX BATT %";
      field6_value = valueRound(maxBatteryPerc, "%.1f");
    }
    if (AppStorage.getSetting("field6") == 18) {
      field6 = "AVG PWR";
      field6_value = valueRound(avgPower, "%.1f");
    }
    if (AppStorage.getSetting("field6") == 19) {
      field6 = "MAX PWR %";
      field6_value = valueRound(maxPower, "%.1f");
    }
  }
  // Calculate the data to display in the field here
  var activityElapsedTime = "";
  var activityElapsedDist = "";
  var activityAvgSpd = "";
  var activityGPSAcc = "";
  var activityStartTimeVal = "";
  var activityTimerState = "";
  var activityTimerTime = "";
  var reset = "no";
  // Calculate the data to display in the field here
  function compute(info) {
    if (info.elapsedTime != null) {
      activityElapsedTime = info.elapsedTime;
    }
    if (info.elapsedDistance != null) {
      activityElapsedDist = info.elapsedDistance;
    }
    if (info.averageSpeed != null) {
      activityAvgSpd = info.averageSpeed;
    }
    if (info.currentLocationAccuracy != null) {
      activityGPSAcc = info.currentLocationAccuracy;
    }
    if (info.startTime != null) {
      activityStartTimeVal = info.startTime.value();
    }
    if (info.timerState != null) {
      activityTimerState = info.timerState;
    }
    if (info.timerTime != null) {
      activityTimerTime = info.timerTime;
    }

    if (eucData.paired == true) {
      if (
        eucData.wheelBrand == 4 ||
        eucData.wheelBrand == 5 ||
        eucData.wheelBrand == 6
      ) {
        // inmotion/VESC send live req
        IM_VESC_frameReq();
      }
      if (delay < 0) {
        updateFitData(info);
        getFieldValues();
        EUCAlarms.checkAlarms();
      } else {
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

  // Update the field layout and display the field data
  function onUpdate(dc) {
    // DEBUG SCREEN
    if (eucData.debug) {
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
        "TrgNb: " + eucData.variaTargetNb,
        Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
      );
      dc.drawText(
        alignAxe - xGap,
        space + yGap,
        Graphics.FONT_TINY,
        "TrgDst: " + eucData.variaTargetDist,
        Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
      );
      dc.drawText(
        alignAxe - 2 * xGap,
        2 * space + yGap,
        Graphics.FONT_TINY,
        "VariaCon: " + eucData.variaConnected,
        Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
      );
      dc.drawText(
        alignAxe - 2 * xGap,
        3 * space + yGap,
        Graphics.FONT_TINY,
        "GPSacc: " + activityGPSAcc,
        Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
      );
      dc.drawText(
        alignAxe - 2 * xGap,
        4 * space + yGap,
        Graphics.FONT_TINY,
        "StrtTime: " + activityStartTimeVal,
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
        /*
        // Should rewrite layout for 240x240 round watches,
        if (eucData.GUI == true) {
          // GUI
          var CurrentTime = System.getClockTime();
          cDrawables[:TimeDate].setText(
            CurrentTime.hour.format("%d") + ":" + CurrentTime.min.format("%02d")
          );

          cDrawables[:TimeDate].setColor(Graphics.COLOR_WHITE);

          // Update label drawables
          cDrawables[:TimeDate].setText(
            // Update time
            System.getClockTime().hour.format("%d") +
              ":" +
              System.getClockTime().min.format("%02d")
          );
          var batteryPercentage = eucData.getBatteryPercentage();

          cDrawables[:BatteryNumber].setText(
            valueRound(batteryPercentage, "%.1f") + "%"
          );
          cDrawables[:TemperatureNumber].setText(
            valueRound(eucData.temperature, "%.1f").toString() + "°C"
          );
          // cDrawables[:BottomSubtitle].setText(diplayStats());
         

          var speedNumberStr = "";

          if (eucData.mainNumber == 0) {
            var speedNumberVal = "";
            speedNumberVal = eucData.correctedSpeed;
            if (speedNumberVal > 100) {
              speedNumberStr = valueRound(
                eucData.correctedSpeed,
                "%d"
              ).toString();
            } else {
              speedNumberStr = valueRound(
                eucData.correctedSpeed,
                "%.1f"
              ).toString();
            }
          }
          if (eucData.mainNumber == 1) {
            var speedNumberVal;
            speedNumberVal = eucData.PWM;
            if (speedNumberVal > 100) {
              speedNumberStr = valueRound(eucData.PWM, "%d").toString();
            } else {
              speedNumberStr = valueRound(eucData.PWM, "%.1f").toString();
            }
          }
          if (eucData.mainNumber == 2) {
            var speedNumberVal;
            speedNumberVal = eucData.getBatteryPercentage();
            if (speedNumberVal > 100) {
              speedNumberStr = valueRound(speedNumberVal, "%d").toString();
            } else {
              speedNumberStr = valueRound(speedNumberVal, "%.1f").toString();
            }
          }
          cDrawables[:SpeedNumber].setText(speedNumberStr);
          //cDrawables[:SpeedArc].setValues(WheelData.currentSpeed.toFloat(), WheelData.speedLimit);
          if (eucData.topBar == 0) {
            cDrawables[:SpeedArc].setValues(eucData.PWM.toFloat(), 100);
          } else {
            cDrawables[:SpeedArc].setValues(
              eucData.correctedSpeed.toFloat(),
              eucData.maxDisplayedSpeed
            );
          }

          cDrawables[:BatteryArc].setValues(batteryPercentage, 100);
          cDrawables[:TemperatureArc].setValues(
            eucData.temperature,
            eucData.maxTemperature
          );
          cDrawables[:TimeDate].setColor(Graphics.COLOR_WHITE);
          cDrawables[:SpeedNumber].setColor(Graphics.COLOR_WHITE);
          cDrawables[:BatteryNumber].setColor(Graphics.COLOR_WHITE);
          cDrawables[:TemperatureNumber].setColor(Graphics.COLOR_WHITE);
          cDrawables[:BottomSubtitle].setColor(Graphics.COLOR_WHITE);

          // END OF GUI
          
        } else {*/
        var gap;
        var scr_height = dc.getHeight();
        var scr_width = dc.getWidth();
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
            scr_height - 2 * gap - (fieldNameFontHeight + fieldValueFontHeight)
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
          field1,
          Graphics.TEXT_JUSTIFY_CENTER
        );
        dc.drawText(
          scr_width / 2,
          gap + fieldNameFontHeight,
          fieldValueFont,
          field1_value,
          Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawText(
          scr_width / 4,
          scr_height / 4,
          fieldNameFont,
          field2,
          Graphics.TEXT_JUSTIFY_CENTER
        );
        dc.drawText(
          scr_width / 4,
          scr_height / 4 + fieldNameFontHeight,
          fieldValueFont,
          field2_value,
          Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawText(
          scr_width - scr_width / 4,
          scr_height / 4,
          fieldNameFont,
          field3,
          Graphics.TEXT_JUSTIFY_CENTER
        );
        dc.drawText(
          scr_width - scr_width / 4,
          scr_height / 4 + fieldNameFontHeight,
          fieldValueFont,
          field3_value,
          Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawText(
          scr_width / 4,
          scr_height / 2 + gap,
          fieldNameFont,
          field4,
          Graphics.TEXT_JUSTIFY_CENTER
        );
        dc.drawText(
          scr_width / 4,
          scr_height / 2 + gap + fieldNameFontHeight,
          fieldValueFont,
          field4_value,
          Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawText(
          scr_width - scr_width / 4,
          scr_height / 2 + gap,
          fieldNameFont,
          field5,
          Graphics.TEXT_JUSTIFY_CENTER
        );
        dc.drawText(
          scr_width - scr_width / 4,
          scr_height / 2 + gap + fieldNameFontHeight,
          fieldValueFont,
          field5_value,
          Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawText(
          scr_width / 2,
          scr_height - gap - fieldNameFontHeight - fieldValueFontHeight,
          fieldNameFont,
          field6,
          Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawText(
          scr_width / 2,
          scr_height - gap - fieldValueFontHeight,
          fieldValueFont,
          field6_value,
          Graphics.TEXT_JUSTIFY_CENTER
        );
        if (
          EUCAlarms.displayingAlert == true &&
          EUCAlarms.displayAlertTimer > 0
        ) {
          EUCAlarms.displayAlertTimer = EUCAlarms.displayAlertTimer - 1;
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

        // North & Wind

        if (eucData.displayNorth == true && Position.getInfo().accuracy >= 2) {
          renderNorthOnUI(scr_width, dc);
        }
        if (eucData.displayWind == true && Position.getInfo().accuracy >= 2) {
          renderWindnUI(scr_width, dc);
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
      var x1 = getXY(screenDiam, 0, screenDiam / 2 - 1, north, 1);
      var x2 = getXY(
        screenDiam,
        0,
        screenDiam / 2 - screenDiam / 30,
        north - screenDiam / 150,
        1
      );
      var x3 = getXY(
        screenDiam,
        0,
        screenDiam / 2 - screenDiam / 30,
        north + screenDiam / 150,
        1
      );
      var pts = [x1, x2, x3];
      dc.setColor(0xd53420, Graphics.COLOR_TRANSPARENT);
      dc.fillPolygon(pts);
    }
  }

  function renderWindnUI(screenDiam, dc) {
    var windBearing = Weather.getCurrentConditions().windBearing;
    var rawNorth = Toybox.Position.getInfo().heading;

    if (rawNorth != null && windBearing != null) {
      var north = rawNorth * -57.2958;
      var wind = windBearing + north;
      var x1 = getXY(screenDiam, 0, screenDiam / 2 - 1, wind, 1);
      var x2 = getXY(
        screenDiam,
        0,
        screenDiam / 2 - screenDiam / 30,
        wind - screenDiam / 150,
        1
      );
      var x3 = getXY(
        screenDiam,
        0,
        screenDiam / 2 - screenDiam / 30,
        wind + screenDiam / 150,
        1
      );
      var pts = [x1, x2, x3];
      dc.setColor(0x0077b6, Graphics.COLOR_TRANSPARENT);
      dc.fillPolygon(pts);
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
    if (
      Storage.getValue("maxTemp") != null &&
      Storage.getValue("minTemp") != null &&
      Storage.getValue("maxVoltage") != null &&
      Storage.getValue("minVoltage") != null &&
      Storage.getValue("maxBatteryPerc") != null &&
      Storage.getValue("minBatteryPerc") != null &&
      Storage.getValue("sessionDistance") != null &&
      Storage.getValue("avgSpeed") != null &&
      Storage.getValue("maxPWM") != null &&
      //Storage.getValue("startingMoment") != null &&
      Storage.getValue("avgCurrent") != null &&
      Storage.getValue("avgPower") != null &&
      Storage.getValue("maxSpeed") != null &&
      Storage.getValue("maxPower") != null &&
      Storage.getValue("maxCurrent") != null &&
      Storage.getValue("sumCurrent") != null &&
      Storage.getValue("sumPower") != null &&
      Storage.getValue("callNb") != null &&
      Storage.getValue("startingEUCTripDistance") != null &&
      Storage.getValue("avgMovingSpeed") != null
    ) {
      maxTemp = Storage.getValue("maxTemp");
      minTemp = Storage.getValue("minTemp");
      maxVoltage = Storage.getValue("maxVoltage");
      minVoltage = Storage.getValue("minVoltage");
      maxBatteryPerc = Storage.getValue("maxBatteryPerc");
      minBatteryPerc = Storage.getValue("minBatteryPerc");
      sessionDistance = Storage.getValue("sessionDistance");
      avgSpeed = Storage.getValue("avgSpeed");
      avgCurrent = Storage.getValue("avgCurrent");
      avgPower = Storage.getValue("avgPower");
      maxSpeed = Storage.getValue("maxSpeed");
      maxCurrent = Storage.getValue("maxCurrent");
      maxPower = Storage.getValue("maxPower");
      sumCurrent = Storage.getValue("sumCurrent");
      sumPower = Storage.getValue("sumPower");
      callNb = Storage.getValue("callNb");
      startingEUCTripDistance = Storage.getValue("startingEUCTripDistance");
      maxPWM = Storage.getValue("maxPWM");
      avgMovingSpeed = Storage.getValue("avgMovingSpeed");
      // startingMoment = new Time.Moment(Storage.getValue("startingMoment"));

      // should only be required for max values
      mMaxSpeedField.setData(maxSpeed);
      mMaxPWMField.setData(maxPWM);
      mMaxTempField.setData(maxTemp);
      mMinVoltageField.setData(minVoltage);
      mMaxVoltageField.setData(maxVoltage);
      mMinBatteryField.setData(minBatteryPerc);
    }
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
    Storage.setValue("avgMovingSpeed", avgMovingSpeed);
    //Storage.setValue("startingMoment", startingMoment.value());
    Storage.setValue("startingEUCTripDistance", startingEUCTripDistance);
  }
  function onTimerStart() {
    // System.println("start");
    /*
    if (
      Storage.getValue("maxTemp") != null &&
      Storage.getValue("minTemp") != null &&
      Storage.getValue("maxVoltage") != null &&
      Storage.getValue("minVoltage") != null &&
      Storage.getValue("maxBatteryPerc") != null &&
      Storage.getValue("minBatteryPerc") != null &&
      Storage.getValue("sessionDistance") != null &&
      Storage.getValue("avgSpeed") != null &&
      Storage.getValue("maxPWM") != null &&
      //Storage.getValue("startingMoment") != null &&
      Storage.getValue("avgCurrent") != null &&
      Storage.getValue("avgPower") != null &&
      Storage.getValue("maxSpeed") != null &&
      Storage.getValue("maxPower") != null &&
      Storage.getValue("maxCurrent") != null &&
      Storage.getValue("sumCurrent") != null &&
      Storage.getValue("sumPower") != null &&
      Storage.getValue("callNb") != null &&
      Storage.getValue("startingEUCTripDistance") != null
    ) {
      maxTemp = Storage.getValue("maxTemp");
      minTemp = Storage.getValue("minTemp");
      maxVoltage = Storage.getValue("maxVoltage");
      minVoltage = Storage.getValue("minVoltage");
      maxBatteryPerc = Storage.getValue("maxBatteryPerc");
      minBatteryPerc = Storage.getValue("minBatteryPerc");
      sessionDistance = Storage.getValue("sessionDistance");
      avgSpeed = Storage.getValue("avgSpeed");
      avgCurrent = Storage.getValue("avgCurrent");
      avgPower = Storage.getValue("avgPower");
      maxSpeed = Storage.getValue("maxSpeed");
      maxCurrent = Storage.getValue("maxCurrent");
      maxPower = Storage.getValue("maxPower");
      sumCurrent = Storage.getValue("sumCurrent");
      sumPower = Storage.getValue("sumPower");
      callNb = Storage.getValue("callNb");
      startingEUCTripDistance = Storage.getValue("startingEUCTripDistance");
      maxPWM = Storage.getValue("maxPWM");
      // startingMoment = new Time.Moment(Storage.getValue("startingMoment"));
    }*/
  }
  function onTimerResume() {
    /*
    //System.println("resume");
    if (
      Storage.getValue("maxTemp") != null &&
      Storage.getValue("minTemp") != null &&
      Storage.getValue("maxVoltage") != null &&
      Storage.getValue("minVoltage") != null &&
      Storage.getValue("maxBatteryPerc") != null &&
      Storage.getValue("minBatteryPerc") != null &&
      Storage.getValue("sessionDistance") != null &&
      Storage.getValue("avgSpeed") != null &&
      Storage.getValue("maxPWM") != null &&
      // Storage.getValue("startingMoment") != null &&
      Storage.getValue("avgCurrent") != null &&
      Storage.getValue("avgPower") != null &&
      Storage.getValue("maxSpeed") != null &&
      Storage.getValue("maxPower") != null &&
      Storage.getValue("maxCurrent") != null &&
      Storage.getValue("sumCurrent") != null &&
      Storage.getValue("sumPower") != null &&
      Storage.getValue("callNb") != null &&
      Storage.getValue("startingEUCTripDistance") != null
    ) {
      maxTemp = Storage.getValue("maxTemp");
      minTemp = Storage.getValue("minTemp");
      maxVoltage = Storage.getValue("maxVoltage");
      minVoltage = Storage.getValue("minVoltage");
      maxBatteryPerc = Storage.getValue("maxBatteryPerc");
      minBatteryPerc = Storage.getValue("minBatteryPerc");
      sessionDistance = Storage.getValue("sessionDistance");
      avgSpeed = Storage.getValue("avgSpeed");
      avgCurrent = Storage.getValue("avgCurrent");
      avgPower = Storage.getValue("avgPower");
      maxSpeed = Storage.getValue("maxSpeed");
      maxCurrent = Storage.getValue("maxCurrent");
      maxPower = Storage.getValue("maxPower");
      sumCurrent = Storage.getValue("sumCurrent");
      sumPower = Storage.getValue("sumPower");
      callNb = Storage.getValue("callNb");
      startingEUCTripDistance = Storage.getValue("startingEUCTripDistance");
      maxPWM = Storage.getValue("maxPWM");
      // startingMoment = new Time.Moment(Storage.getValue("startingMoment"));
    }*/
  }

  function IM_VESC_frameReq() {
    if (eucData.wheelBrand == 4 || eucData.wheelBrand == 5) {
      if (IM_count > 0 && bleDelegate != null) {
        bleDelegate.lastPacketType = "live";
        bleDelegate.IM_VESC_reqLiveData();
        IM_count = IM_count - 1;
      }
      if (IM_count <= 0 && bleDelegate != null) {
        bleDelegate.lastPacketType = "stats";
        bleDelegate.IM_reqStats();
        IM_count = 30;
      }
    }
    if (eucData.wheelBrand == 6) {
      bleDelegate.IM_VESC_reqLiveData();
    }
  }
}
