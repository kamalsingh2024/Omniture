//
//  TMMobile.h
//  ADBMobileSamples
//
//  Created by Deyu Wang on 28/10/2014.
//  Copyright (c) 2014 Adobe. All rights reserved.
//

#import "ADBMobile.h"


typedef NS_ENUM(NSUInteger, TMMobileSupportedApps) {
    TM_AFL,
    TM_AFLW,
    TM_AFL_FANTASY,
    TM_AFL_KIDS,
    TM_AFLFLM_WCE,
    TM_NRL,
    TM_NRL_FANTASY,
    TM_SPORTS_FAN,
    TM_NETBALL,
    TM_FOXTEL,
    TM_MOVIES,
    TM_AFL_TIPPING,
    TM_AFL_CLUB_ADELAIDE_CROWS,
    TM_AFL_CLUB_BRISBANE_LIONS,
    TM_AFL_CLUB_CARLTON_BLUES,
    TM_AFL_CLUB_COLLINGWOOD_MAGPIES,
    TM_AFL_CLUB_ESSENDON_BOMBERS,
    TM_AFL_CLUB_FREMANTLE,
    TM_AFL_CLUB_GWS,
    TM_AFL_CLUB_GEELONG_CATS,
    TM_AFL_CLUB_GOLD_COAST,
    TM_AFL_CLUB_HAWTHORN_HAWKS,
    TM_AFL_CLUB_KANGAROOS,
    TM_AFL_CLUB_MELBOURNE_DEMONS,
    TM_AFL_CLUB_PORT_ADELAIDE,
    TM_AFL_CLUB_RICHMOND_TIGERS,
    TM_AFL_CLUB_STKILDA_SAINTS,
    TM_AFL_CLUB_SYDNEY_SWANS,
    TM_AFL_CLUB_WEST_COAST_EAGLES,
    TM_AFL_CLUB_WESTERN_BULLDOGS,
    TM_PUCK_REMOTE,
    TM_MYFOOTBALL,
    TD_DEVICE_CARE,
};

typedef NS_ENUM(NSUInteger, TMMobileCustomSubscriptionStatus) {
    TM_SUBSCRIPTION_INVENUE
};

@interface TMMobile : ADBMobile

/**
 * TM: Initial configuration of Adobe Mobile Tracking framework.
 * @param appName Supporte App ID, e.g. TM_AFL, TM_NRL
 * @param appVer App versione.g. @"3.1.1"
 * @param getAdID Direct the framework to retrieve advertising ID or not.
 * @param debugLogging Enable debug logging or not.
 * @return  void
 */
+(void) tmInitConfig:(TMMobileSupportedApps)appName appVer:(NSString*)appVer getAdID:(BOOL)getAdID debugLogging:(BOOL)debug disableSectionReports:(BOOL)disableSectionReports;


/**
 * TM: Check if the device is on Telstra network by leveraging CPT data.
 * @return  0-nonTelstra, 1-Telstra, 2-Unknown
 */
+ (BOOL) tmIsTelstraMobile;
/**
 * TM: Check if the device is on Telstra network by leveraging CPT data.
 * @return  0-nonTelstra, 1-Telstra, 2-Unknown
 */
+ (NSInteger) tmIsTelstra;

/**
 * TM: Check UID by leveraging CPT data. tmInitConfig needs to be called before this method can return a value.
 * @return  10 digits UID or empty string
 */
+ (NSString*) tmGetUID;

/**
 * TM: Get Adobe Visitor ID. tmInitConfig needs to be called before this method can return a value.
 * @return  String
 */
+ (NSString*) tmAdobeDeviceID;

/**
 * TM: Get Adobe Carrier Name. tmInitConfig needs to be called before this method can return a value.
 * @return  String
 */
+ (NSString*) tmGetCarrier;

/**
 * TM: Method to retrieve connection type.
 * @return  "wifi" or "cellular"
 * TM: Check if the device is on WiFi network.
 * @return  0-nonWiFi, 1-WiFi, 2-Unknown
 */
+(NSInteger) tmIsWiFi;

/**
 * TM: Get Apple Advertising ID. tmInitConfig needs to be called before this method can return a value.
 * @return  String
 */
+ (NSString*) tmAdID;

/**
 * TM: Get Siebel hash ID by leveraging CPT data. tmInitConfig needs to be called before this method can return a value.
 * @return  String
 */
+ (NSString*) tmSiebelHashID;


/**
 * TM: TM version of trackState function to send a page view image request to SiteCatalyst.
 * @param state Page name, e.g. @"menu", @"match centre:home", @"match centre:tournament name:round 1"
 * @param subscriptionStatus Is the user's custom subscription status.
 * @param data Customized context data to be sent with the image request.
 * @return void
 */
+(void) tmTrackState:(NSString *)state
  subscriptionStatus:(TMMobileCustomSubscriptionStatus)subscriptionStatus
                data:(NSDictionary *)data;

/**
 * TM: TM version of trackState function to send a page view image request to SiteCatalyst.
 * @param state Page name, e.g. @"menu", @"match centre:home", @"match centre:tournament name:round 1"
 * @param subscribed Is the user a subscriber or not.
 * @param data Customized context data to be sent with the image request.
 * @return void
 */
+(void) tmTrackState:(NSString *)state
          subscribed:(BOOL)subscribed
                data:(NSDictionary *)data;

/**
 * TM: TM version of trackState function to send a page view image request to SiteCatalyst.
 * @param state Page name, e.g. @"menu", @"match centre:home", @"match centre:tournament name:round 1"
 * @param data Customized context data to be sent with the image request.
 * @return void
 */
+(void) tmTrackState:(NSString *)state
                data:(NSDictionary *)data;

/**
 * TM: TM version of trackAction function to track an action with context data.
 * @param action a string pointer containing the action value to be tracked.
 * @param subscribed Is the user a subscriber or not.
 * @param data a dictionary pointer containing the context data to be tracked.
 */
+(void) tmTrackAction:(NSString *)action subscribed:(BOOL)subscribed data:(NSDictionary *)data;

/**
 * TM: TM version of trackAction function to send a page view image request to SiteCatalyst.
 * @param state Page name, e.g. @"menu", @"match centre:home", @"match centre:tournament name:round 1"
 * @param subscriptionStatus Is the user's custom subscription status.
 * @param data Customized context data to be sent with the image request.
 * @return void
 */
+(void) tmTrackAction:(NSString *)state
   subscriptionStatus:(TMMobileCustomSubscriptionStatus)subscriptionStatus
                 data:(NSDictionary *)data;

/**
 * TM: TM version of trackAction function to track an action with context data.
 * @param action a string pointer containing the action value to be tracked.
 * @param data a dictionary pointer containing the context data to be tracked.
 */
+(void) tmTrackAction:(NSString *)action data:(NSDictionary *)data;

/**
 * TM: Method to call when user tunes in a live stream.
 * @param streamTitle The title of the stream, e.g. @"AFL Live"
 * @return  void
 */
+(void) tmLiveStreamTuneIn:(NSString*)streamTitle;

/**
 * TM: Method to call every 20 minutes after the user has tuned in, to keep the session alive.
 * The method will accumulate time played by 1200 seconds automatically.
 * @param streamTitle The title of the stream, e.g. @"AFL Live"
 * @return  void
 */
+(void) tmLiveStreamKeepLive:(NSString*)streamTitle;

/**
 * TM: Method to call when user tunes out a live stream.
 * @param streamTitle The title of the stream, e.g. @"AFL Live"
 * @param timePlayedSeconds Counts the time, in seconds, spent in the live stream since the last data collection image request(tune in or keep live).
 * @return  void
 */
+(void) tmLiveStreamTuneOut:(NSString*)streamTitle timePlayedSeconds:(NSString*)timePlayed;

/**
 * TM: Method to call before playing back VOD.
 * @param mediaName The title of the media being played, e.g. @"AFLVideo:Most Important Player: Beams v Hanley"
 * @param mediaLength The length of the media being played.
 * @param playerName Name of the player, e.g. @"MPMoviePlayer"
 * @param mediaLength ID of the player, e.g. @"MPMoviePlayer1"
 * @return  ADBMediaSettings the media settings configuration object
 */
+(ADBMediaSettings *) tmConfigureVODTracking:(NSString*)mediaName mediaLength:(double)mediaLength playerName:(NSString*)playerName playerID:(NSString*)playerID;

@end
