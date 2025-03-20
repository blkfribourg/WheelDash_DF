import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class GarminEUCApp extends Application.AppBase {
  private var view;
  //  private var delegate;
  private var eucBleDelegate;
  private var currentProfile;

  function initialize() {
    AppBase.initialize();
  }

  // onStart() is called on application start up
  function onStart(state as Dictionary?) as Void {
    // Sandbox zone
    // end of sandbox
    // ------------------------------------------------------
  }

  // Return the initial view of your application here
  function getInitialView() {
    //Connect IQ7
    // function getInitialView() as Array<Views or InputDelegates>? {
    //queue = new BleQueue();

    return [new GarminEUCDF()]; //Connect IQ7
    // return [view] as Array<Views or InputDelegates>?;
  }
}
