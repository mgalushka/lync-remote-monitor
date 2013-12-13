import ketai.camera.*;
import ketai.net.nfc.record.*;
import ketai.net.*;
import ketai.ui.*;
import ketai.cv.facedetector.*;
import ketai.sensors.*;
import ketai.net.nfc.*;
import ketai.net.wifidirect.*;
import ketai.data.*;
import ketai.net.bluetooth.*;

import apwidgets.*;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;

import com.google.gson.Gson;

import android.app.*;
import android.content.*; 
import com.google.android.gms.gcm.*;
import android.content.pm.*;

APWidgetContainer widgetContainer; 
APEditText userIdField;
APButton registerPhoneBtn;

DefaultHttpClient httpClient;

GoogleCloudMessaging gcm;
String regid;

// registration URL in push service
// -H application-id:value-from-backendless-console
// -H secret-key:value-from-backendless-console
// -H Content-Type:application/json
// 
String PUSH_SERVICE_REGISTRATION = "https://api.backendless.com/v1/messaging/registrations";

String REGISTER_DEVICE = "http://192.168.1.103/omxplayer-web-controls-php/open.php?path=";
String ROOT = "http://192.168.1.103/omxplayer-web-controls-php/open.php?path=";

KetaiList filesystemList;
ArrayList lst = new ArrayList();

String USER_ID = "username";
String userId = null;

// Google Project Number: 302299434458 
String SENDER_ID = "302299434458";


String EXTRA_MESSAGE = "message";
String PROPERTY_REG_ID = "registration_id";
String PROPERTY_APP_VERSION = "appVersion";

int PLAY_SERVICES_RESOLUTION_REQUEST = 9000;

int W, H;

void setup() {

  W = displayWidth;
  H = displayHeight;

  //To load settings
  SharedPreferences settings = ((Activity) this).getSharedPreferences("UserId", Activity.MODE_PRIVATE);
  userId = settings.getString(USER_ID, null);

  try
  {
    httpClient = new DefaultHttpClient();
  } 
  catch( Exception e ) { 
    e.printStackTrace();
  }

  widgetContainer = new APWidgetContainer(this); //create new container for widgets
  userIdField = new APEditText(W/8, H/5, (3*W)/4, H/15);
  registerPhoneBtn = new APButton((3*W)/8, (2*H)/5, W/4, H/15, "Register"); 

  widgetContainer.addWidget(userIdField); //place textField in container
  widgetContainer.addWidget(registerPhoneBtn); //place textField in container

  //background(0);  
  //rectMode(CENTER);
}

void exit() {
  if (httpClient != null) {
    //httpClient.getConnectionManager().shutdown();
  }
}


void draw() {
  background(0);
  //fill(0);

  if (userId == null) {
    //text(userIdField.getText(), 10, 10); //display the text in the text field
  }
  else {
    //text(userId, 10, 10); //display the text in the text field
  }
}

void onClickWidget(APWidget widget) {
  if (widget == registerPhoneBtn) { //if it was button1 that was clicked
    print ("clicked button, registering device");
    retrieveRegistrationId();
  }
}

void keyPressed() {
}

void mousePressed() {
  try {
  } 
  catch (Exception e) {
    e.printStackTrace();
  }
}


// this is code to call 
void retrieveRegistrationId() {
  if (checkPlayServices()) {
    gcm = GoogleCloudMessaging.getInstance(this);
    regid = getRegistrationId(this.getApplicationContext());

    if (regid.isEmpty()) {
      registerInBackground();
    }
  }
}


boolean checkPlayServices() {
  int resultCode = GooglePlayServicesUtil.isGooglePlayServicesAvailable(this);
  if (resultCode != ConnectionResult.SUCCESS) {
    if (GooglePlayServicesUtil.isUserRecoverableError(resultCode)) {
      GooglePlayServicesUtil.getErrorDialog(resultCode, this, 
      PLAY_SERVICES_RESOLUTION_REQUEST).show();
    } 
    else {
      print("This device is not supported.");
    }
    return false;
  }
  return true;
}  

String getRegistrationId(Context context) {
  final SharedPreferences prefs = getGCMPreferences(context);
  String registrationId = prefs.getString(PROPERTY_REG_ID, "");
  if (registrationId.isEmpty()) {
    print("Registration not found.");
    return "";
  }
  // Check if app was updated; if so, it must clear the registration ID
  // since the existing regID is not guaranteed to work with the new
  // app version.
  int registeredVersion = prefs.getInt(PROPERTY_APP_VERSION, Integer.MIN_VALUE);
  int currentVersion = getAppVersion(context);
  if (registeredVersion != currentVersion) {
    print("App version changed.");
    return "";
  }
  return registrationId;
}

private SharedPreferences getGCMPreferences(Context context) {
  // This sample app persists the registration ID in shared preferences, but
  // how you store the regID in your app is up to you.
  return ((Activity) this).getSharedPreferences("Lync", Activity.MODE_PRIVATE);
}

String registerInBackground() {
  String msg = "";
  try {
    if (gcm == null) {
      gcm = GoogleCloudMessaging.getInstance(this.getApplicationContext());
    }
    regid = gcm.register(SENDER_ID);
    msg = "Device registered, registration ID=" + regid;

    // You should send the registration ID to your server over HTTP,
    // so it can use GCM/HTTP or CCS to send messages to your app.
    // The request to your server should be authenticated if your app
    // is using accounts.
    sendRegistrationIdToBackend();

    // For this demo: we don't need to send it because the device
    // will send upstream messages to a server that echo back the
    // message using the 'from' address in the message.

    // Persist the regID - no need to register again.
    storeRegistrationId(this.getApplicationContext(), regid);
  } 
  catch (IOException ex) {
    msg = "Error :" + ex.getMessage();
    // If there is an error, don't just keep trying to register.
    // Require the user to click a button again, or perform
    // exponential back-off.
  }
  return msg;
}


private void sendRegistrationIdToBackend() {
  // Your implementation here.
  // post to service
  print("here we need to send registration key to backend");
}

private static int getAppVersion(Context context) {
  try {
    PackageInfo packageInfo = context.getPackageManager()
      .getPackageInfo(context.getPackageName(), 0);
    return packageInfo.versionCode;
  } 
  catch (Exception e) {
    // should never happen
    throw new RuntimeException("Could not get package name: " + e);
  }
}

private void storeRegistrationId(Context context, String regId) {
  final SharedPreferences prefs = getGCMPreferences(context);
  int appVersion = getAppVersion(context);
  print("Saving regId on app version " + appVersion);
  SharedPreferences.Editor editor = prefs.edit();
  editor.putString(PROPERTY_REG_ID, regId);
  editor.putInt(PROPERTY_APP_VERSION, appVersion);
  editor.commit();
}

void sendToServer0(String path) {
  try {
    println("Send get request for path: " + ROOT);
    HttpGet httpGet   = new HttpGet(ROOT);

    HttpResponse response = httpClient.execute( httpGet );
    HttpEntity   entity   = response.getEntity();

    println("----------------------------------------");
    println( response.getStatusLine() );
    println("----------------------------------------");

    if ( entity != null ) entity.writeTo( System.out );
    if ( entity != null ) entity.consumeContent();
  } 
  catch (IOException io) {
    io.printStackTrace();
  }
}


void sendToServer(String command) {
  try {
    println("Execute command: " + command);
    HttpPost httpPost   = new HttpPost(ROOT);
    HttpParams postParams = new BasicHttpParams();
    postParams.setParameter( "act", command );
    postParams.setParameter( "arg", "undefined" ); 
    httpPost.setParams( postParams );

    HttpResponse response = httpClient.execute( httpPost );
    HttpEntity   entity   = response.getEntity();

    Gson gson = new Gson(); // Or use new GsonBuilder().create();

    println("----------------------------------------");
    println( response.getStatusLine() );
    println("----------------------------------------");

    String json = EntityUtils.toString(entity);
    println ("json = " + json);

    //if ( entity != null ) entity.writeTo( System.out );
    //if ( entity != null ) entity.consumeContent();
  } 
  catch (IOException io) {
    io.printStackTrace();
  }
}

