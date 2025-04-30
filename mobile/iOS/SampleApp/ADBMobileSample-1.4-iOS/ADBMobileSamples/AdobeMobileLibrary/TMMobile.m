//
//  TMMobile.m
//  ADBMobileSamples
//
//  Created by Deyu Wang on 28/10/2014.
//  Copyright (c) 2014 Adobe. All rights reserved.
//

#import "TMMobile.h"
#import "Reachability.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
@import AdSupport;

static NSArray * s_pPrefix = nil; // prefix for page name
static NSArray * s_hPrefix = nil; // prefix for hierarchy
static NSString * s_server = nil; // value of server
static NSString * s_appName = nil;
static NSMutableDictionary * s_basicData = nil;
static NSInteger isTelstra = 2;  // 3-Unknown, 0-False, 1-True
static NSString *TM_VERSION = @"iOS-20190405-01"; // TM Framework version. Needs to be updated when the framework is updated.

@implementation TMMobile

+(void)initialize{
    if (!s_pPrefix)
        s_pPrefix = @[];
    if (!s_basicData) {
        s_basicData = [NSMutableDictionary dictionary];
    }
}

+ (void)getCPT
{
    // Send a synchronous request to get CPT string
    NSString *dataUrl = @"http://medrx.telstra.com.au/online.php";
    NSURL *url = [NSURL URLWithString:dataUrl];
    
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              // 4: Handle response here
                                              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                              isTelstra = 0;
                                              if (error == nil && 200 == (long)[httpResponse statusCode])
                                              {
                                                  NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                  
                                                  NSString *cptPattern = @"extraAdCallInfo = '(.*)'";
                                                  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:cptPattern
                                                                                                                         options:0 error:NULL];
                                                  NSTextCheckingResult *match = [regex firstMatchInString:str options:0 range:NSMakeRange(0, [str length])];
                                                  if (match != nil) {
                                                      NSString *cpt = [str substringWithRange:[match rangeAtIndex:1]];
                                                      [s_basicData setObject:cpt forKey:@"user.cpt"];
                                                  }
                                                  
                                                  NSString *hashIdPattern = @"cn=([a-zA-Z0-9]+);";
                                                  NSRegularExpression *hashIdRegex = [NSRegularExpression regularExpressionWithPattern:hashIdPattern
                                                                                                                               options:0 error:NULL];
                                                  NSTextCheckingResult *hashIdMatch = [hashIdRegex firstMatchInString:str options:0 range:NSMakeRange(0, [str length])];
                                                  if (hashIdMatch != nil) {
                                                      NSString *hashId = [str substringWithRange:[hashIdMatch rangeAtIndex:1]];
                                                      [s_basicData setObject:hashId forKey:@"user.hashId"];
                                                      isTelstra = 1;
                                                  }
                                                  
                                                  NSString *uidPattern = @"po=([0-9]+)'";
                                                  NSRegularExpression *uidRegex = [NSRegularExpression regularExpressionWithPattern:uidPattern
                                                                                                                            options:0 error:NULL];
                                                  NSTextCheckingResult *uidMatch = [uidRegex firstMatchInString:str options:0 range:NSMakeRange(0, [str length])];
                                                  if (uidMatch != nil) {
                                                      NSString *uid = [str substringWithRange:[uidMatch rangeAtIndex:1]];
                                                      [s_basicData setObject:uid forKey:@"user.muid"];
                                                      isTelstra = 1;
                                                  }
                                              }
                                          }];
    
    [downloadTask resume];
}

+ (NSInteger) tmIsTelstra
{
    return isTelstra;
}

+ (NSString*) tmGetCarrier
{
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    NSString *tmCarrier = [NSString stringWithFormat:@"%@",[carrier carrierName]];
    return tmCarrier;
}

+ (NSString*) tmGetUID
{
    if ([s_basicData objectForKey:@"user.muid"]) {
        return [s_basicData objectForKey:@"user.muid"];
    } else {
        return @"";
    }
}

+ (NSString*) tmAdobeDeviceID
{
    if ([s_basicData objectForKey:@"device.id"]) {
        return [s_basicData objectForKey:@"device.id"];
    } else {
        return @"";
    }
}

+ (NSString*) tmAdID
{
    if ([s_basicData objectForKey:@"device.adid"]) {
        return [s_basicData objectForKey:@"device.adid"];
    } else {
        return @"";
    }
}

+ (NSString*) tmSiebelHashID
{
    if ([s_basicData objectForKey:@"user.hashId"]) {
        return [s_basicData objectForKey:@"user.hashId"];
    } else {
        return @"";
    }
}

+(void)tmInitConfig:(TMMobileSupportedApps) appName
             appVer:(NSString*)appVer
            getAdID:(BOOL)getAdID
       debugLogging:(BOOL)debug {
    
    // set app related info
    [self setAppRelatedInfo:appName];
    
    // device and app static info
    [s_basicData setObject:[self retrieveAppType] forKey:@"app.type"]; // iPhoneApp, iPadApp, AppWatchApp
    [s_basicData setObject:appVer forKey:@"app.version"]; // e.g. 3.1.1
    [s_basicData setObject:TM_VERSION forKey:@"app.tmversion"];
 
    // populate visitor ID if not set
    if (![s_basicData objectForKey:@"device.id"])
        [s_basicData setObject:[self retrieveVisitorIdentification] forKey:@"device.id"];
    if (getAdID && ![s_basicData objectForKey:@"device.adid"])
        [s_basicData setObject:[self retrieveIdentifierForAdvertising] forKey:@"device.adid"];
    
    [self getCPT];

    // add the mcorgid
    [s_basicData setObject:@"98DC73AE52E13F1E0A490D4C@AdobeOrg" forKey:@"&&mcorgid"];
    
    
    // setup your traits dictionary
    NSDictionary *traits = @{@"trait":@"18"};
    // submit your signal and take action on results
    [ADBMobile audienceSignalWithData:traits
                             callback:^(NSDictionary *response) {
                                 if ([response count] > 0 ) {
                                     //[s_basicData setObject:[*response] forKey:@"aam.profile"];
                                 }
                             }];

    // populate aam profile
    [s_basicData setObject:[self audienceVisitorProfile] forKey:@"aam.profile"];
    
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    [ADBMobile setAdvertisingIdentifier:idfa];
    
    [super collectLifecycleDataWithAdditionalData:s_basicData];
    [super setDebugLogging:debug];
    
}

// tmTrackState function to be called when there's no change to subscription status
+(void) tmTrackState:(NSString *)state
                data:(NSDictionary *)data {
    [self tmTrackStateInternal:state data:data];
}

// tmTrackStat function to be called when subscription status is changed between subscriber and non-subscriber.
+(void) tmTrackState:(NSString *)state
          subscribed:(BOOL)subscribed
                data:(NSDictionary *)data {
    
    NSMutableDictionary * dataToSend = [[NSMutableDictionary alloc]initWithDictionary:data];
    // populate user and device information
    if (subscribed) {
        [dataToSend setObject:@"subscriber" forKey:@"user.subscriberstatus"];
    } else {
        [dataToSend setObject:@"non subscriber" forKey:@"user.subscriberstatus"];
    }
    
    [self tmTrackStateInternal:state data:dataToSend];
}

// tmTrackStat function to be called when subscription status customized, e.g. "in-venue".
+(void) tmTrackState:(NSString *)state
  subscriptionStatus:(TMMobileCustomSubscriptionStatus) subscriptionStatus
                data:(NSDictionary *)data {
    
    NSMutableDictionary * dataToSend = [[NSMutableDictionary alloc]initWithDictionary:data];
    
    switch (subscriptionStatus) {
        case TM_SUBSCRIPTION_INVENUE :
            [dataToSend setObject:@"in-venue" forKey:@"user.subscriberstatus"];
            break;
    }
    
    [self tmTrackStateInternal:state data:dataToSend];
}


// tmTrackStat function to be called when subscription status is changed between subscriber and non-subscriber.
+(void) tmTrackAction:(NSString *)action
                 data:(NSDictionary *)data {
    [self tmTrackActionInternal:action data:data];
}

// tmTrackAction function to be called when there's no change to subscription status
+(void) tmTrackAction:(NSString *)action
           subscribed:(BOOL)subscribed
                 data:(NSDictionary *)data {
    NSMutableDictionary * dataToSend = [[NSMutableDictionary alloc]initWithDictionary:data];
    // populate user and device information
    if (subscribed) {
        [dataToSend setObject:@"subscriber" forKey:@"user.subscriberstatus"];
    } else {
        [dataToSend setObject:@"non subscriber" forKey:@"user.subscriberstatus"];
    }
    
    [self tmTrackActionInternal:action data:dataToSend];
}

// tmTrackAction function to be called when subscription status customized, e.g. "in-venue".
+(void) tmTrackAction:(NSString *)action
   subscriptionStatus:(TMMobileCustomSubscriptionStatus) subscriptionStatus
                 data:(NSDictionary *)data {
    
    NSMutableDictionary * dataToSend = [[NSMutableDictionary alloc]initWithDictionary:data];
    
    switch (subscriptionStatus) {
        case TM_SUBSCRIPTION_INVENUE :
            [dataToSend setObject:@"in-venue" forKey:@"user.subscriberstatus"];
            break;
    }
    
    [self tmTrackActionInternal:action data:dataToSend];
}


+(void) tmLiveStreamTuneIn:(NSString*)streamTitle {
    NSMutableDictionary *contextData = [[NSMutableDictionary alloc]initWithDictionary:s_basicData];
    
    [contextData setObject:streamTitle forKey:@"livestream.title"];
    [contextData setObject:@"1" forKey:@"livestream.tunein"];
    [ADBMobile trackAction:@"livestream tune in" data:contextData];
}


+(void) tmLiveStreamKeepLive:(NSString*)streamTitle {
    NSMutableDictionary *contextData = [[NSMutableDictionary alloc]initWithDictionary:s_basicData];
    
    [contextData setObject:streamTitle forKey:@"livestream.title"];
    [contextData setObject:@"1200" forKey:@"livestream.offset"];
    [ADBMobile trackAction:@"livestream keep live" data:contextData];
    
}
+(void) tmLiveStreamTuneOut:(NSString*)streamTitle timePlayedSeconds:(NSString*)timePlayed {
    NSMutableDictionary *contextData = [[NSMutableDictionary alloc]initWithDictionary:s_basicData];
    
    [contextData setObject:streamTitle forKey:@"livestream.title"];
    [contextData setObject:timePlayed forKey:@"livestream.offset"];
    [contextData setObject:@"1" forKey:@"livestream.tuneout"];
    [ADBMobile trackAction:@"livestream tune out" data:contextData];
}

+(ADBMediaSettings *) tmConfigureVODTracking:(NSString*)mediaName mediaLength:(double)mediaLength playerName:(NSString*)playerName playerID:(NSString*)playerID{
    ADBMediaSettings *mediaSettings = [ADBMobile mediaCreateSettingsWithName:mediaName length:mediaLength playerName:playerName playerID:playerID];
    mediaSettings.milestones = @"25,50,75";
    mediaSettings.segmentByMilestones = YES;
    
    // seconds tracking - sends a hit every 1200 seconds to keep session alive
    mediaSettings.trackSeconds = 1200;
    
    return mediaSettings;
}

// PRIVATE METHODS DEFINED BELOW THIS LINE

+(void) tmTrackStateInternal:(NSString *)state
                        data:(NSDictionary *)data {
    // populate visitor ID if not set
    if (![s_basicData objectForKey:@"device.id"])
        [s_basicData setObject:[self retrieveVisitorIdentification] forKey:@"device.id"];
    
    // pageName e.g. "match centre:round 1:team a vs team b
    NSMutableArray *pageNameArray = [NSMutableArray arrayWithArray:s_pPrefix ];
    [pageNameArray addObjectsFromArray:[state componentsSeparatedByString:@":"]];
    
    NSMutableArray *hierArray = [NSMutableArray arrayWithArray:s_hPrefix ];
    [hierArray addObjectsFromArray:[state componentsSeparatedByString:@":"]];
    
    NSString * pageNameStr = [pageNameArray componentsJoinedByString:@":"];
    NSString * hierStr = [hierArray componentsJoinedByString:@"|"];
    // populate page hierarchy information
    NSMutableDictionary * dataToSend = [[NSMutableDictionary alloc]initWithDictionary:s_basicData];
    [dataToSend setObject:hierStr forKey:@"pageinfo.hier"];
    [dataToSend setObject:s_server forKey:@"pageinfo.server"];
    int hierVarNum = [hierArray count] > 6 ? 6 : (int)[hierArray count];
    for (int i=0; i<hierVarNum; i++) {
        switch (i) {
            case 0:
                [dataToSend setObject:hierArray[i] forKey:@"pageinfo.division"];
                break;
            case 1:
                [dataToSend setObject:hierArray[i] forKey:@"pageinfo.subdivision"];
                break;
            case 2:
                [dataToSend setObject:hierArray[i] forKey:@"pageinfo.site"];
                break;
            case 3:
                [dataToSend setObject:hierArray[i] forKey:@"pageinfo.section"];
                break;
            case 4:
                [dataToSend setObject:hierArray[i] forKey:@"pageinfo.appsection"];
                break;
            case 5:
                [dataToSend setObject:hierArray[i] forKey:@"pageinfo.landingpage"];
                break;
            default:
                break;
        }
    }
    
    [dataToSend setObject:[self retrieveConnectionType] forKey:@"device.connectiontype"];
    
    //populate custom context data
    if (data) {
        [dataToSend addEntriesFromDictionary:data];
    }
    [super trackState:pageNameStr data:dataToSend];
}

+(void) tmTrackActionInternal:(NSString *)action
                         data:(NSDictionary *)data {
    // populate visitor ID if not set
    if (![s_basicData objectForKey:@"device.id"])
        [s_basicData setObject:[self retrieveVisitorIdentification] forKey:@"device.id"];
    
    NSMutableDictionary *contextData = [[NSMutableDictionary alloc]initWithDictionary:s_basicData];
    
    [contextData setObject:[self retrieveConnectionType] forKey:@"device.connectiontype"];
    
    [contextData setObject:s_server forKey:@"pageinfo.server"];
    
    //populate custom context data
    if (data) {
        [contextData addEntriesFromDictionary:data];
    }
    [ADBMobile trackAction:action data:contextData];
}

// The value returned from this method should be set to the visitor ID parameter that is placed within the URL
+ (NSString *)retrieveVisitorIdentification {
    
    //Check to see if vid is set, if so grab and return.
    if ([super userIdentifier]) {
        return [super userIdentifier];
    }
    // If not set, get aid and return
    else if ([super trackingIdentifier]) {
        return [super trackingIdentifier];
    }
    //If not set, get mid and return.
    else {
        return [super visitorMarketingCloudID];
    }
}


+ (NSString *)retrieveConnectionType {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if (status == ReachableViaWiFi)
    {
        return @"wifi";
    }
    //else if (status == ReachableViaWWAN)
    else {
        return @"cellular";
    }
    //    else if(status == NotReachable)
    //    {
    //        //No internet
    //    }
    
}

+(NSInteger) tmIsWiFi {
    NSInteger result = 0;
    NSString * conType = [self retrieveConnectionType];
    if ([conType isEqualToString:@"wifi"]) {
        result = 1;
    }
    return result;
}

+(NSString * ) retrieveAppType {
    if ([[UIDevice currentDevice].model hasPrefix:@"iPhone"]==YES) {
        return @"iPhoneApp";
    } else if ([[UIDevice currentDevice].model hasPrefix:@"iPad"]==YES) {
        return @"iPadApp";
    } else if ([[UIDevice currentDevice].model hasPrefix:@"iPod"]==YES) {
        return @"iPodApp";
    }else
        return @"AppleWatchApp";
}

+ (NSString *)retrieveIdentifierForAdvertising {
    // Check whether advertising tracking is enabled
    if([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
        NSUUID *identifier = [[ASIdentifierManager sharedManager] advertisingIdentifier];
        return [identifier UUIDString];
    }
    
    // Get and return IDFA
    return @"";
}

+(void) setAppRelatedInfo:(TMMobileSupportedApps) appName {
    
    switch (appName) {
        case TM_AFL :
            s_pPrefix = @[@"BM",@"AFL"];
            s_hPrefix = @[@"BM",@"Sport",@"AFL"];
            s_server = @"AFL iOS App";
            break;
        case TM_AFLW :
            s_pPrefix = @[@"BM",@"AFLW"];
            s_hPrefix = @[@"BM",@"Sport",@"AFLW"];
            s_server = @"AFLW iOS App";
            break;
        case TM_AFL_FANTASY :
            s_pPrefix = @[@"BM",@"AFL Fantasy"];
            s_hPrefix = @[@"BM",@"Sport",@"AFL Fantasy"];
            s_server = @"AFL Fantasy iOS App";
            break;
        case TM_AFL_TIPPING :
            s_pPrefix = @[@"BM",@"AFL Tipping"];
            s_hPrefix = @[@"BM",@"Sport",@"AFL Tipping"];
            s_server = @"AFL Tipping iOS App";
            break;
        case TM_AFLFLM_WCE :
            s_pPrefix = @[@"BM",@"AFL WCE Commentary Cup"];
            s_hPrefix = @[@"BM",@"Sport",@"AFL WCE Commentary Cup"];
            s_server = @"AFL WCE Commentary Android App";
            break;
        case TM_SPORTS_FAN :
            s_pPrefix = @[@"BM",@"SportsFan"];
            s_hPrefix = @[@"BM",@"Sport",@"bpsport"];
            s_server = @"SportsFan Android App";
            break;
        case TM_AFL_KIDS :
            s_pPrefix = @[@"BM",@"AFL Kids"];
            s_hPrefix = @[@"BM",@"Sport",@"AFL Kids"];
            s_server = @"AFL Kids iOS App";
            break;
        case TM_NRL :
            s_pPrefix = @[@"BM",@"NRL"];
            s_hPrefix = @[@"BM",@"Sport",@"NRL"];
            s_server = @"NRL iOS App";
            break;
        case TM_NRL_FANTASY :
            s_pPrefix = @[@"BM",@"NRL Fantasy"];
            s_hPrefix = @[@"BM",@"Sport",@"NRL Fantasy"];
            s_server = @"NRL Fantasy iOS App";
            break;
        case TM_NETBALL :
            s_pPrefix = @[@"BM",@"Netball"];
            s_hPrefix = @[@"BM",@"Sport",@"Netball"];
            s_server = @"Netball iOS App";
            break;
        case TM_MOVIES :
            s_pPrefix = @[@"BM",@"Movies"];
            s_hPrefix = @[@"BM",@"Entertainment",@"Movies"];
            s_server = @"Movies iOS App";
            break;
        case TM_FOXTEL :
            s_pPrefix = @[@"BM",@"Foxtel"];
            s_hPrefix = @[@"BM",@"Entertainment",@"Foxtel"];
            s_server = @"Foxtel iOS App";
            break;
            // Begin AFL Clubs
        case TM_AFL_CLUB_ADELAIDE_CROWS :
            s_pPrefix = @[@"BM",@"AFL Club App - Adelaide Crows"];
            s_hPrefix = @[@"BM",@"Sport",@"AFL Club App - Adelaide Crows"];
            s_server = @"AFL Club iOS App";
            break;
        case TM_AFL_CLUB_BRISBANE_LIONS :
            s_pPrefix = @[@"BM",@"AFL Club App - Brisbane Lions"];
            s_hPrefix = @[@"BM",@"Sport",@"AFL Club App - Brisbane Lions"];
            s_server = @"AFL Club iOS App";
            break;
        case TM_AFL_CLUB_CARLTON_BLUES :
            s_pPrefix = @[@"BM",@"AFL Club App - Carlton Blues"];
            s_hPrefix = @[@"BM",@"Sport",@"AFL Club App - Carlton Blues"];
            s_server = @"AFL Club iOS App";
            break;
        case TM_AFL_CLUB_COLLINGWOOD_MAGPIES :
            s_pPrefix = @[@"BM",@"AFL Club App - Collingwood Magpies"];
            s_hPrefix = @[@"BM",@"Sport",@"AFL Club App - Collingwood Magpies"];
            s_server = @"AFL Club iOS App";
            break;
        case TM_AFL_CLUB_ESSENDON_BOMBERS :
            s_pPrefix = @[@"BM",@"AFL Club App - Essendon Bombers"];
            s_hPrefix = @[@"BM",@"Sport",@"AFL Club App - Essendon Bombers"];
            s_server = @"AFL Club iOS App";
            break;
        case TM_AFL_CLUB_FREMANTLE :
            s_pPrefix = @[@"BM",@"AFL Club App - Fremantle"];
            s_hPrefix = @[@"BM",@"Sport",@"AFL Club App - Fremantle"];
            s_server = @"AFL Club iOS App";
            break;
        case TM_AFL_CLUB_GWS :
            s_pPrefix = @[@"BM",@"AFL Club App - GWS"];
            s_hPrefix = @[@"BM",@"Sport",@"AFL Club App - GWS"];
            s_server = @"AFL Club iOS App";
            break;
        case TM_AFL_CLUB_GEELONG_CATS :
            s_pPrefix = @[@"BM",@"AFL Club App - Geelong Cats"];
            s_hPrefix = @[@"BM",@"Sport",@"AFL Club App - Geelong Cats"];
            s_server = @"AFL Club iOS App";
            break;
        case TM_AFL_CLUB_GOLD_COAST :
            s_pPrefix = @[@"BM",@"AFL Club App - Gold Coast"];
            s_hPrefix = @[@"BM",@"Sport",@"AFL Club App - Gold Coast"];
            s_server = @"AFL Club iOS App";
            break;
        case TM_AFL_CLUB_HAWTHORN_HAWKS :
            s_pPrefix = @[@"BM",@"AFL Club App - Hawthorn Hawks"];
            s_hPrefix = @[@"BM",@"Sport",@"AFL Club App - Hawthorn Hawks"];
            s_server = @"AFL Club iOS App";
            break;
        case TM_AFL_CLUB_KANGAROOS :
            s_pPrefix = @[@"BM",@"AFL Club App - Kangaroos"];
            s_hPrefix = @[@"BM",@"Sport",@"AFL Club App - Kangaroos"];
            s_server = @"AFL Club iOS App";
            break;
        case TM_AFL_CLUB_MELBOURNE_DEMONS :
            s_pPrefix = @[@"BM",@"AFL Club App - Melbourne Demons"];
            s_hPrefix = @[@"BM",@"Sport",@"AFL Club App - Melbourne Demons"];
            s_server = @"AFL Club iOS App";
            break;
        case TM_AFL_CLUB_PORT_ADELAIDE :
            s_pPrefix = @[@"BM",@"AFL Club App - Port Adelaide"];
            s_hPrefix = @[@"BM",@"Sport",@"AFL Club App - Port Adelaide"];
            s_server = @"AFL Club iOS App";
            break;
        case TM_AFL_CLUB_RICHMOND_TIGERS :
            s_pPrefix = @[@"BM",@"AFL Club App - Richmond Tigers"];
            s_hPrefix = @[@"BM",@"Sport",@"AFL Club App - Richmond Tigers"];
            s_server = @"AFL Club iOS App";
            break;
        case TM_AFL_CLUB_STKILDA_SAINTS :
            s_pPrefix = @[@"BM",@"AFL Club App - St.Kilda Saints"];
            s_hPrefix = @[@"BM",@"Sport",@"AFL Club App - St.Kilda Saints"];
            s_server = @"AFL Club iOS App";
            break;
        case TM_AFL_CLUB_SYDNEY_SWANS :
            s_pPrefix = @[@"BM",@"AFL Club App - Sydney Swans"];
            s_hPrefix = @[@"BM",@"Sport",@"AFL Club App - Sydney Swans"];
            s_server = @"AFL Club iOS App";
            break;
        case TM_AFL_CLUB_WEST_COAST_EAGLES :
            s_pPrefix = @[@"BM",@"AFL Club App - West Coast Eagles"];
            s_hPrefix = @[@"BM",@"Sport",@"AFL Club App - West Coast Eagles"];
            s_server = @"AFL Club iOS App";
            break;
        case TM_AFL_CLUB_WESTERN_BULLDOGS :
            s_pPrefix = @[@"BM",@"AFL Club App - Western Bulldogs"];
            s_hPrefix = @[@"BM",@"Sport",@"AFL Club App - Western Bulldogs"];
            s_server = @"AFL Club iOS App";
            break;
            // End AFL Clubs
        case TM_PUCK_REMOTE :
            s_pPrefix = @[@"PUCK",@"TTVPlus"];
            s_hPrefix = @[@"PUCK",@"TTVPlus"];
            s_server = @"PUCK TTVPlus iOS App";
            break;
        case TM_MYFOOTBALL :
            s_pPrefix = @[@"BM",@"MYFOOTBALL"];
            s_hPrefix = @[@"BM",@"Sport",@"MyFootball"];
            s_server = @"MyFootball iOS App";
            break;
        case TD_DEVICE_CARE :
            s_pPrefix = @[@"TD",@"Service",@"DeviceCare"];
            s_hPrefix = @[@"TD",@"Service",@"DeviceCare"];
            s_server = @"TD Service DeviceCare iOS App";
            break;
        default:
            s_pPrefix = @[@"BM",@"DEV"];
            s_hPrefix = @[@"BM",@"Sport",@"DEV"];
            s_server = @"BM Dev iOS App";
            break;
    }
}

@end
