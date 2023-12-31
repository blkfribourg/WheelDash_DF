using Toybox.WatchUi;
using Toybox.Graphics;

class GarminEUCDF extends WatchUi.DataField {
  var delay = 3;
  var firstCall = true;
  hidden var field1 = "NC";
  hidden var field2 = "NC";
  hidden var field3 = "NC";
  hidden var field4 = "NC";
  hidden var field5 = "NC";
  hidden var field6 = "NC";
  hidden var field1_value = 0.0;
  hidden var field2_value = 0.0;
  hidden var field3_value = 0.0;
  hidden var field4_value = 0.0;
  hidden var field5_value = 0.0;
  hidden var field6_value = 0.0;

  const SPEED_FIELD_ID = 0;
  const PWM_FIELD_ID = 1;
  const VOLTAGE_FIELD_ID = 2;
  const CURRENT_FIELD_ID = 3;
  const POWER_FIELD_ID = 4;
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
  /*
  const SPEED_FIELD_ID_MILES = 16;
  const TRIPDISTANCE_FIELD_ID_MILES = 17;
  const MAXSPEED_FIELD_ID_MILES = 18;
  const AVGSPEED_FIELD_ID_MILES = 19;
  */
  const MINVOLTAGE_FIELD_ID = 16;
  const MAXVOLTAGE_FIELD_ID = 17;
  const MINBATTERY_FIELD_ID = 18;
  const MAXBATTERY_FIELD_ID = 19;
  const MINTEMP_FIELD_ID = 20;

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

  function initialize() {
    DataField.initialize();
    fieldsInitialize();
  }

  function fieldsInitialize() {
    mSpeedField = createField(
      "speed",
      SPEED_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "km/h" }
    );

    mPWMField = createField(
      "PWM",
      PWM_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "%" }
    );
    mVoltageField = createField(
      "Voltage",
      VOLTAGE_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "V" }
    );
    /*
    mCurrentField = createField(
      "Current",
      CURRENT_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "A" }
    );
    mPowerField = createField(
      "Power",
      POWER_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "W" }
    );
    */
    mTempField = createField(
      "Temperature",
      TEMP_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "°C" }
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

    mMaxPWMField = createField(
      "Max_PWM",
      MAXPWM_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "%" }
    );
    /*
    mMaxCurrentField = createField(
      "Max_Current",
      MAXCURRENT_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "A" }
    );
    mMaxPowerField = createField(
      "Max_Power",
      MAXPOWER_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "W" }
    );
    */
    mMaxTempField = createField(
      "Max_Temp",
      MAXTEMP_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "°C" }
    );
    mAvgSpeedField = createField(
      "Avg_Speed",
      AVGSPEED_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "km/h" }
    );
    /*
    mAvgCurrentField = createField(
      "Avg_Current",
      AVGCURRENT_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "A" }
    ); 
    mAvgPowerField = createField(
      "Avg_Power",
      AVGPOWER_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "W" }
    );
   */
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
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "%" }
    );
    /*
    mMaxBatteryField = createField(
      "Max_Battery",
      MAXBATTERY_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "%" }
    );
   
    mMinTempField = createField(
      "Min_Temp",
      MINTEMP_FIELD_ID,
      FitContributor.DATA_TYPE_FLOAT,
      { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "°C" }
    );*/

    // set fields to 0
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
  var maxTemp = 0.0;
  var minTemp = 0.0;
  var currentPWM = 0.0;
  var correctedSpeed = 0.0;
  var currentCurrent = 0.0;
  var currentVoltage = 0.0;
  var currentBatteryPerc = 0.0;
  var sumCurrent = 0.0;
  var callNb = 0.0;
  var currentPower = 0.0;
  var sumPower = 0.0;
  var sessionDistance = 0.0;
  var startingEUCTripDistance = 0.0;
  var startingMoment = 0.0;
  var minVoltage = 0.0;
  var maxVoltage = 0.0;
  var minBatteryPerc = 0.0;
  var maxBatteryPerc = 0.0;
  var avgSpeed = 0.0;
  var avgCurrent = 0.0;
  var avgPower = 0.0;

  function updateFitData() {
    callNb++;
    currentVoltage = eucData.getVoltage();
    currentBatteryPerc = eucData.getBatteryPercentage();
    currentPWM = eucData.getPWM();
    correctedSpeed = eucData.getCorrectedSpeed();
    currentCurrent = eucData.getCurrent();
    currentPower = currentCurrent * currentVoltage;

    mSpeedField.setData(correctedSpeed); // id 0
    mPWMField.setData(currentPWM); //id 1
    mVoltageField.setData(currentVoltage); // id 2
    //    mCurrentField.setData(currentCurrent); // id 3
    //    mPowerField.setData(currentPower); // id 4
    mTempField.setData(eucData.temperature); // id 5

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

    if (eucData.temperature > maxTemp) {
      maxTemp = eucData.temperature;
      mMaxTempField.setData(maxTemp); // id 11
    }
    if (eucData.temperature < minTemp) {
      minTemp = eucData.temperature;
      // mMinTempField.setData(minTemp); // id 11
    }
    if (currentVoltage > maxVoltage) {
      maxVoltage = currentVoltage;
      mMaxVoltageField.setData(maxVoltage);
    }
    if (currentVoltage < minVoltage) {
      minVoltage = currentVoltage;
      mMinVoltageField.setData(minVoltage);
    }

    if (currentBatteryPerc > maxBatteryPerc) {
      maxBatteryPerc = currentBatteryPerc;
      // mMaxBatteryField.setData(maxBatteryPerc);
    }
    if (currentBatteryPerc < minBatteryPerc) {
      minBatteryPerc = currentBatteryPerc;
      mMinBatteryField.setData(minBatteryPerc);
    }

    var currentMoment = new Time.Moment(Time.now().value());
    var elaspedTime = startingMoment.subtract(currentMoment);
    //System.println("elaspsed :" + elaspedTime.value());
    if (elaspedTime.value() != 0 && eucData.totalDistance > 0) {
      if (startingEUCTripDistance < 0) {
        startingEUCTripDistance = eucData.totalDistance;
      }
      sessionDistance =
        (eucData.totalDistance - startingEUCTripDistance) *
        eucData.speedCorrectionFactor;
      avgSpeed = sessionDistance / (elaspedTime.value() / 3600.0);
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
    //mAvgCurrentField.setData(sumCurrent / callNb); // id 13
    //mAvgPowerField.setData(sumPower / callNb); // id 14
  }
  function resetVariables() {
    startingMoment = new Time.Moment(Time.now().value());
    startingEUCTripDistance = -1;
    minVoltage = 255.0;
    maxVoltage = 0.0;
    minBatteryPerc = 101.0;
    maxBatteryPerc = 0.0;
    maxSpeed = 0.0;
    maxPWM = 0.0;
    maxCurrent = 0.0;
    maxPower = 0.0;
    minTemp = 255.0;
    maxTemp = -255.0;
    sumCurrent = 0.0;
    sumPower = 0.0;
    avgSpeed = 0.0;
    avgCurrent = 0.0;
    avgPower = 0.0;
    callNb = 0;
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
      field1_value = valueRound(eucData.temperature, "%.1f");
    }
    if (AppStorage.getSetting("field1") == 5) {
      field1 = "TT DIST";
      field1_value = valueRound(eucData.totalDistance, "%.1f");
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
      field1 = "MAX CURR";
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
      field2_value = valueRound(eucData.temperature, "%.1f");
    }
    if (AppStorage.getSetting("field2") == 5) {
      field2 = "TT DIST";
      field2_value = valueRound(eucData.totalDistance, "%.1f");
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
      field2 = "MAX PWR %";
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
      field3_value = valueRound(eucData.temperature, "%.1f");
    }
    if (AppStorage.getSetting("field3") == 5) {
      field3 = "TT DIST";
      field3_value = valueRound(eucData.totalDistance, "%.1f");
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
      field4_value = valueRound(eucData.temperature, "%.1f");
    }
    if (AppStorage.getSetting("field4") == 5) {
      field4 = "TT DIST";
      field4_value = valueRound(eucData.totalDistance, "%.1f");
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
      field5_value = valueRound(eucData.temperature, "%.1f");
    }
    if (AppStorage.getSetting("field5") == 5) {
      field5 = "TT DIST";
      field5_value = valueRound(eucData.totalDistance, "%.1f");
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
      field6_value = valueRound(eucData.temperature, "%.1f");
    }
    if (AppStorage.getSetting("field6") == 5) {
      field6 = "TT DIST";
      field6_value = valueRound(eucData.totalDistance, "%.1f");
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
  function compute(info) {
    if (eucData.paired == true) {
      if (delay < 0) {
        updateFitData();
        getFieldValues();
      } else {
        resetVariables(); // dirty
        delay = delay - 1;
      }

      /*
      System.println("correctedSpeed :" + correctedSpeed);
      System.println("currentPWM :" + currentPWM);
      System.println("currentVoltage :" + currentVoltage);
      System.println("temperature :" + eucData.temperature);
      System.println("maxSpeed :" + maxSpeed);
      System.println("maxPWM :" + maxPWM);
      System.println("maxTemp" + maxTemp);
      System.println("minTemp:" + minTemp);
      System.println("sessionDistance" + sessionDistance);
      System.println("avgSpeed" + avgSpeed);
      */
    }
  }

  // Update the field layout and display the field data
  function onUpdate(dc) {
    var gap = dc.getWidth() / 40;
    var scr_height = dc.getHeight();
    var scr_width = dc.getWidth();
    var fieldNameFont = Graphics.FONT_XTINY;
    var fieldValueFont = Graphics.FONT_MEDIUM;

    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    dc.clear();
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
    dc.drawLine(gap, scr_height / 2, scr_width - 2 * gap, scr_height / 2);
    dc.drawLine(
      scr_width / 2,
      2 * gap +
        (Graphics.getFontHeight(fieldNameFont) +
          Graphics.getFontHeight(fieldValueFont)),
      scr_width / 2,
      scr_height / 2 - 2 * gap
    );
    dc.drawLine(
      scr_width / 2,
      scr_height / 2 + 2 * gap,
      scr_width / 2,
      scr_height -
        2 * gap -
        (Graphics.getFontHeight(fieldNameFont) +
          Graphics.getFontHeight(fieldValueFont))
    );

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.drawText(
      scr_width / 2,
      gap,
      fieldNameFont,
      field1,
      Graphics.TEXT_JUSTIFY_CENTER
    );
    dc.drawText(
      scr_width / 2,
      gap + Graphics.getFontHeight(fieldNameFont),
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
      scr_height / 4 + Graphics.getFontHeight(fieldNameFont),
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
      scr_height / 4 + Graphics.getFontHeight(fieldNameFont),
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
      scr_height / 2 + gap + Graphics.getFontHeight(fieldNameFont),
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
      scr_height / 2 + gap + Graphics.getFontHeight(fieldNameFont),
      fieldValueFont,
      field5_value,
      Graphics.TEXT_JUSTIFY_CENTER
    );

    dc.drawText(
      scr_width / 2,
      scr_height -
        gap -
        Graphics.getFontHeight(fieldNameFont) -
        Graphics.getFontHeight(fieldValueFont),
      fieldNameFont,
      field6,
      Graphics.TEXT_JUSTIFY_CENTER
    );

    dc.drawText(
      scr_width / 2,
      scr_height - gap - Graphics.getFontHeight(fieldValueFont),
      fieldValueFont,
      field6_value,
      Graphics.TEXT_JUSTIFY_CENTER
    );
    //View.onUpdate(dc);
  }
}
