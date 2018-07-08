import twitter4j.conf.*;
import twitter4j.api.*;
import twitter4j.*;

import java.util.List;
import java.util.Iterator;

import processing.serial.*;
import cc.arduino.*;

ConfigurationBuilder cb;
Twitter twitter;
Arduino arduino;

int tweetPin=3;

String searchResult = "";
String mustMatch = "";

ArrayList<String> twittersList;

void setup() {
  size(600, 600);
  background(180);

  ConfigurationBuilder cb = new ConfigurationBuilder();
  cb.setOAuthConsumerKey("xFKdQBcR354rcqKbLush7AIiW");
  cb.setOAuthConsumerSecret("o5kmnl1jk5ZW1EYlqXMJnuLXxXFBCveBA5FQ7IikmUv7QUudvK");
  cb.setOAuthAccessToken("1006206305659506690-TNihLA5SGjIzo73o705llbxIQT6FOC");
  cb.setOAuthAccessTokenSecret("iQEk216LUUc8nP618Y7sW3urMxInoTd8J7yl7H8Xb6X6n");

  twitter = new TwitterFactory(cb.build()).getInstance();

  arduino = new Arduino(this, Arduino.list()[2], 57600);
  arduino.pinMode(tweetPin, Arduino.OUTPUT);
}


void draw() {
  background(180);
  noStroke();
  fill(70, 55, 100);

  searchResult = searchTwitter("#kiel");

  if (searchResult.equals("") == false) { // wenn kein _leeres_ suchergebnis
    arduino.digitalWrite(tweetPin, Arduino.HIGH);
    arduino.digitalWrite(tweetPin, Arduino.LOW);
    ellipse(300, 300, 120, 120);
  }
}



int interval = 10 * 1000;
int timer = interval;

String searchTwitter(String keyword) {
  int now = millis();
  if (now <= timer + interval) {
    return "";
  }

  println("search twitter");
  timer = now;

  ArrayList<String> tweetMessages = new ArrayList<String>();

  Query query = new Query(keyword);
  query.setCount(10);

  try {
    QueryResult result = twitter.search(query);
    List<Status> tweets = result.getTweets();
    for (Status tw : tweets) {
      String msg = tw.getText();
      println(msg);
      tweetMessages.add(msg);
    }
  }
  catch(TwitterException te) {
    println("Couldn't connect: " + te);
    RateLimitStatus rl = te.getRateLimitStatus();
    if (rl != null) {
      int resetIn = rl.getSecondsUntilReset();
      timer = millis() + resetIn * 1000;
      println("Seconds until reset: " + resetIn);
    }
  }
  try {
    String text;
    text = tweetMessages.get(0);
    return text;
  } 
  catch(Exception e) {
    println("Propably no tweets received: " + e);
    return "";
  }
}