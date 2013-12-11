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

import android.content.SharedPreferences;

APWidgetContainer widgetContainer; 
APEditText userIdField;

DefaultHttpClient httpClient;

// registration URL in push service
// -H application-id:value-from-backendless-console
// -H secret-key:value-from-backendless-console
// -H Content-Type:application/json
// 
String PUSH_SERVICE_REGISTRATION = "https://api.backendless.com/v1/messaging/registrations";

String REGISTER_DEVICE = "http://192.168.1.103/omxplayer-web-controls-php/open.php?path=";
String ROOT = "http://192.168.1.103/omxplayer-web-controls-php/open.php?path=";

// Google Project Number: 302299434458 

KetaiList filesystemList;
ArrayList lst = new ArrayList();

String USER_ID = "username";
String userId = null;

void setup() {

  //To load settings
  SharedPreferences settings = getSharedPreferences("UserId", Activity.MODE_PRIVATE);
  userId = settings.getString(USER_ID);

  try
  {
    httpClient = new DefaultHttpClient();
  } 
  catch( Exception e ) { 
    e.printStackTrace();
  }

  widgetContainer = new APWidgetContainer(this); //create new container for widgets
  userIdField = new APEditText(20, 100, 150, 50); //create a textfield from x- and y-pos., width and height
  widgetContainer.addWidget(userIdField); //place textField in container

  background(0);  
  rectMode(CENTER);
}

void exit() {
  if (httpClient != null) {
    //httpClient.getConnectionManager().shutdown();
  }
}


void draw() {
  background(255);
  fill(0);

  if (userId == null) {
  }
  else {
    text(userId, 10, 10); //display the text in the text field
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

