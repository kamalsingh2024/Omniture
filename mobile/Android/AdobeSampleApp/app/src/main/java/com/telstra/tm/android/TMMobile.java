package com.telstra.tm.android;

import android.app.Activity;
import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.telephony.TelephonyManager;

import com.adobe.mobile.Analytics;
import com.adobe.mobile.Config;
import com.adobe.mobile.MediaSettings;
import com.adobe.mobile.Visitor;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by deyuwang on 29/01/15.
 */


public class TMMobile {

    public static final String TM_VERSION = "Android-20200210-01";

    public static ArrayList<String> s_pPrefix; // prefix for page name
    public static ArrayList<String> s_hPrefix; // prefix for hierarchy
    public static String s_server; // value of server
    public static HashMap<String, Object> s_basicData = new HashMap<String, Object>();
    private static int isTelstra = 2; // 0-false, 1-true, 2-unknown
    private static Boolean isTelstraMobile = false; //false=not on telstra mobile network, true=on telstra mobile network

    public static Context s_appContext;
    private static String lastSection = "";
    private static Boolean disableSectionReports = false;


    public static void tmInitConfig(Context appContext, TMMobileSupportedApps appName, String appVer,
                                    Boolean getAdId, Boolean debug,
                                    Boolean sectionReports ) {

        Config.setContext(appContext);
        Config.setDebugLogging(debug);

        setAppRelatedInfo(appName);
        if (getAdId) {
            new TMMobileAdIdAsyncTask(appContext).execute(s_basicData);
            //Visitor.syncIdentifier(); //OmnitureConstants.AUDIENCE_MANAGER_USER_ID, hashedAccountID(), VisitorID.VisitorIDAuthenticationState.VISITOR_ID_AUTHENTICATION_STATE_AUTHENTICATED);
        }
        tmGetCPT();

        s_basicData.put("app.type", "AndroidApp");
        s_basicData.put("app.version", appVer);
        s_basicData.put("pageinfo.server", s_server);
        s_basicData.put("app.tmversion", TM_VERSION);
        s_appContext = appContext;
        disableSectionReports = sectionReports;

        // populate aam profile

        // add the mcorgid
        //s_basicData.put("&&mcorgid", "98DC73AE52E13F1E0A490D4C@AdobeOrg");

        // setup your traits dictionary
        // submit your signal and take action on results
        //HashMap aamTraits = new HashMap<String, Object>();
        //aamTraits.put("trait", "b");
        //AudienceManager.signalWithData(s_basicData, new AudienceManager.AudienceManagerCallback<Map<String, Object>>() {
        //    @Override
        //    public void call(Map<String, Object> item) {
        //        // segments come back here, normally found in the segs object of your json
        //    }
        //});
        // populate aam profile
        //s_basicData.put("aam.profile", getVisitorProfile());

        if (s_basicData.get("device.id") ==null && retrieveVisitorIdentification()!=null) {
            s_basicData.put("device.id", retrieveVisitorIdentification());
        }
    }

    public static void tmGetCPT() {
        new TMMobileCPTAsyncTask().execute(s_basicData);

    }

    public static int tmIsTelstra() {
        return TMMobile.isTelstra;
    }

    public static boolean tmIsTelstraMobile() {
        return TMMobile.isTelstraMobile;
    }


    public static String tmGetUID() {
        if (s_basicData.get("user.muid") ==null) {
            return "";
        } else {
            return (String)s_basicData.get("user.muid");
        }
    }
    public static String tmGetCarrier() {
        TelephonyManager telephonyManager = ((TelephonyManager) s_appContext.getSystemService(Context.TELEPHONY_SERVICE));
        return (String) telephonyManager.getNetworkOperatorName();
    }



    public static String tmAdobeDeviceID() {
        if (s_basicData.get("device.id") ==null) {
            return "";
        } else {
            return (String)s_basicData.get("device.id");
        }
    }

    public static String tmAdID() {
        if (s_basicData.get("device.adid") ==null) {
            return "";
        } else {
            return (String)s_basicData.get("device.adid");
        }
    }

    public static String tmGSiebelHashID() {
        if (s_basicData.get("user.hashId") ==null) {
            return "";
        } else {
            return (String)s_basicData.get("user.hashId");
        }
    }

    public static void tmSetIsTelstra(int isTelstra) {
        TMMobile.isTelstra = isTelstra;
    }

    public static void tmSetIsTelstraMobile(boolean isTelstraMobile) {
        TMMobile.isTelstraMobile = isTelstraMobile;
    }


    public static void tmCollectLifecycleData(Activity activity) {
        Config.collectLifecycleData(activity, s_basicData);
        //Config.collectLifecycleData();
    }


    public static void tmTrackState(String state, boolean subscribed, Map<String,Object> contextData) {
        HashMap<String, Object> dataToSend = new HashMap<String, Object>(s_basicData);

        // populate user information
        if (subscribed) {
            dataToSend.put("user.subscriberstatus", "subscriber");
        } else {
            dataToSend.put("user.subscriberstatus", "non subscriber");
        }

        if (contextData != null)
            dataToSend.putAll(contextData);

        tmTrackStateInternal(state, dataToSend);
    }

    public static void tmTrackState(String state,  TMMobileCustomSubscriptionStatus subscriptionStatus, Map<String,Object> contextData) {
        HashMap<String, Object> dataToSend = new HashMap<String, Object>(s_basicData);


        switch (subscriptionStatus) {
            case TM_SUBSCRIPTION_INVENUE :
                dataToSend.put("user.subscriberstatus", "in-venue");
                break;
        }

        if (contextData != null)
            dataToSend.putAll(contextData);

        tmTrackStateInternal(state, dataToSend);
    }

    public static void tmTrackState(String state, Map<String,Object> contextData) {
        tmTrackStateInternal(state, contextData);
    }

    public static void tmTrackAction(String action, boolean subscribed, Map<String,Object> contextData) {
        HashMap<String, Object> dataToSend = new HashMap<String, Object>(s_basicData);

        // populate user and device information
        if (subscribed) {
            dataToSend.put("user.subscriberstatus", "subscriber");
        } else {
            dataToSend.put("user.subscriberstatus", "non subscriber");
        }

        if (contextData != null)
            dataToSend.putAll(contextData);

        tmTrackActionInternal(action, dataToSend);
    }

    public static void tmTrackAction(String state,  TMMobileCustomSubscriptionStatus subscriptionStatus, Map<String,Object> contextData) {
        HashMap<String, Object> dataToSend = new HashMap<String, Object>(s_basicData);


        switch (subscriptionStatus) {
            case TM_SUBSCRIPTION_INVENUE :
                dataToSend.put("user.subscriberstatus", "in-venue");
                break;
        }

        if (contextData != null)
            dataToSend.putAll(contextData);

        tmTrackActionInternal(state, dataToSend);
    }

    public static void tmTrackAction(String action, Map<String,Object> contextData) {
        tmTrackActionInternal(action, contextData);
    }

    public static void tmLiveStreamTuneIn(String streamTitle) {
        HashMap<String, Object> contextData = new HashMap<String, Object>(s_basicData);

        contextData.put("livestream.title", streamTitle);
        contextData.put("livestream.tunein", "1");

        Analytics.trackAction("livestream tune in: " +streamTitle, contextData);
    }

    public static void tmLiveStreamKeepLive(String streamTitle) {
        HashMap<String, Object> contextData = new HashMap<String, Object>(s_basicData);

        contextData.put("livestream.title", streamTitle);
        contextData.put("livestream.offset", "1200");

        Analytics.trackAction("livestream keep live: " + streamTitle, contextData);
    }

    public static void tmLiveStreamTuneOut(String streamTitle, String timePlayedSeconds) {
        HashMap<String, Object> contextData = new HashMap<String, Object>(s_basicData);

        contextData.put("livestream.title", streamTitle);
        contextData.put("livestream.offset", timePlayedSeconds);
        contextData.put("livestream.tuneout", "1");

        Analytics.trackAction("livestream tune out: " + streamTitle, contextData);
    }

    public static MediaSettings tmConfigureVODTracking(String mediaName, double mediaLength, String playerName, String playerID) {
        MediaSettings settings = MediaSettings.settingsWith(mediaName, mediaLength, playerName, playerID);
        settings.milestones = "25,50,75";
        settings.segmentByMilestones = true;
        settings.trackSeconds = 1200;

        return settings;
    }

    private static void tmTrackStateInternal(String state, Map<String,Object> contextData) {

        if (s_basicData.get("device.id") ==null && retrieveVisitorIdentification()!=null) {
            s_basicData.put("device.id", retrieveVisitorIdentification());
        }

        ArrayList<String> pageNameArray = new ArrayList<>(s_pPrefix);
        ArrayList<String> hierNameArray = new ArrayList<>(s_hPrefix);
        String[] path = state.split(":");
        for (int i=0;i<path.length;++i) {
            pageNameArray.add(path[i]);
            hierNameArray.add(path[i]);
        }

        String pageNameStr = tmJoin(pageNameArray, ":");
        String hierStr = tmJoin(hierNameArray, "|");

        HashMap<String, Object> dataToSend = new HashMap<String, Object>(s_basicData);
        dataToSend.put("pageinfo.hier", hierStr);

        int hierVarNum = hierNameArray.size() > 6 ? 6 : hierNameArray.size();
        for (int i=0; i<hierVarNum; i++) {
            switch (i) {
                case 0:
                    dataToSend.put("pageinfo.division", hierNameArray.get(i));
                    break;
                case 1:
                    dataToSend.put("pageinfo.subdivision", hierNameArray.get(i));
                    break;
                case 2:
                    dataToSend.put("pageinfo.site", hierNameArray.get(i));
                    break;
                case 3:
                    dataToSend.put("pageinfo.section", hierNameArray.get(i));
                    break;
                case 4:
                    dataToSend.put("pageinfo.appsection", hierNameArray.get(i));
                    break;
                case 5:
                    dataToSend.put("pageinfo.landingpage", hierNameArray.get(i));
                    break;
                default:
                    break;
            }
        }

        dataToSend.put("device.connectiontype", retrieveConnectionType());

        String appsection = (String)dataToSend.get("pageinfo.appsection");

        if (contextData != null)
            dataToSend.putAll(contextData);

        if (!disableSectionReports || appsection == null) {
            Analytics.trackState(pageNameStr, dataToSend);
            lastSection = "";
        }
        else if(appsection != null && ! lastSection.equals(appsection)) {
            lastSection = (String)dataToSend.get("pageinfo.appsection");
            //only report on new sections
            Analytics.trackState(pageNameStr, dataToSend);
        }
    }

    private static void tmTrackActionInternal(String action, Map<String,Object> contextData) {
        if (s_basicData.get("device.id")==null && retrieveVisitorIdentification()!=null) {
            s_basicData.put("device.id", retrieveVisitorIdentification());
        }

        HashMap<String, Object> dataToSend = new HashMap<String, Object>(s_basicData);
        dataToSend.put("device.connectiontype", retrieveConnectionType());

        if (contextData != null)
            dataToSend.putAll(contextData);

        Analytics.trackAction(action, dataToSend);
    }


    private static String retrieveConnectionType() {
        ConnectivityManager cm =
                (ConnectivityManager) s_appContext.getSystemService(Context.CONNECTIVITY_SERVICE);

        if (cm == null || cm.getActiveNetworkInfo()==null) {
            return "no network";
        }

        NetworkInfo activeNetwork = cm.getActiveNetworkInfo();
        if ( activeNetwork.getType() == ConnectivityManager.TYPE_WIFI )
            return "wifi";
        else
            return "cellular";

    }

    public static int tmIsWiFi() {
        int result = 0;

        String conType = retrieveConnectionType();

        if (conType.equals("wifi")) {
            result = 1;
        } else if (conType.equals("no network")) {
            result = 2;
        }
        return result;
    }

    private static String retrieveVisitorIdentification() {
        if ( Config.getUserIdentifier()!=null )
            return Config.getUserIdentifier();
        else if (Analytics.getTrackingIdentifier()!=null) {
            return Analytics.getTrackingIdentifier();
        } else {
            return Visitor.getMarketingCloudId();
        }
    }

    private static void setAppRelatedInfo(TMMobileSupportedApps appName) {
        switch (appName) {
            case TM_AFL :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","AFL"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","AFL"}));
                s_server = "AFL Android App";
                break;
            case TM_AFLW :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","AFLW"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","AFLW"}));
                s_server = "AFLW Android App";
                break;
            case TM_AFL_TIPPING :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","AFL Tipping"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","AFL Tipping"}));
                s_server = "AFL Tipping Android App";
                break;
            case TM_AFL_FANTASY :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","AFL Fantasy"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","AFL Fantasy"}));
                s_server = "AFL Fantasy Android App";
                break;
            case TM_AFL_KIDS :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","AFL Kids"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","AFL Kids"}));
                s_server = "AFL Kids Android App";
                break;
            case TM_AFLFLM_WCE :
                s_pPrefix = new ArrayList < String > (Arrays.asList(new String[] {"BM","AFL WCE Commentary Cup"}));
                s_hPrefix = new ArrayList < String > (Arrays.asList(new String[] {"BM", "Sport","AFL WCE Commentary Cup"}));
                s_server = "AFL WCE Commentary Android App";
            case TM_SPORTS_FAN :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","SportsFan"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","bpsport"}));
                s_server = "SportsFan Android App";
                break;
            case TM_NRL :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","NRL"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","NRL"}));
                s_server = "NRL Android App";
                break;
            case TM_NRL_FANTASY :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","NRL Fantasy"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","NRL Fantasy"}));
                s_server = "NRL Fantasy Android App";
                break;
            case TM_NETBALL :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Netball"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","Netball"}));
                s_server = "Netball Android App";
                break;
            case TM_MOVIES :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Movies"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Entertainment","Movies"}));
                s_server = "Movies Android App";
                break;
            case TM_FOXTEL :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Foxtel"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Entertainment","Foxtel"}));
                s_server = "Foxtel Android App";
                break;
            // Begin AFL Clubs
            case TM_AFL_CLUB_ADELAIDE_CROWS :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","AFL Club App - Adelaide Crows"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","AFL Club App - Adelaide Crows"}));
                s_server = "AFL Club Android App";
                break;
            case TM_AFL_CLUB_BRISBANE_LIONS :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","AFL Club App - Brisbane Lions"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","AFL Club App - Brisbane Lions"}));
                s_server = "AFL Club Android App";
                break;
            case TM_AFL_CLUB_CARLTON_BLUES :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","AFL Club App - Carlton Blues"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","AFL Club App - Carlton Blues"}));
                s_server = "AFL Club Android App";
                break;
            case TM_AFL_CLUB_COLLINGWOOD_MAGPIES :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","AFL Club App - Collingwood Magpies"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","AFL Club App - Collingwood Magpies"}));
                s_server = "AFL Club Android App";
                break;
            case TM_AFL_CLUB_ESSENDON_BOMBERS :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","AFL Club App - Essendon Bombers"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","AFL Club App - Essendon Bombers"}));
                s_server = "AFL Club Android App";
                break;
            case TM_AFL_CLUB_FREMANTLE :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","AFL Club App - Fremantle"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","AFL Club App - Fremantle"}));
                s_server = "AFL Club Android App";
                break;
            case TM_AFL_CLUB_GWS :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","AFL Club App - GWS"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","AFL Club App - GWS"}));
                s_server = "AFL Club Android App";
                break;
            case TM_AFL_CLUB_GEELONG_CATS :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","AFL Club App - Geelong Cats"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","AFL Club App - Geelong Cats"}));
                s_server = "AFL Club Android App";
                break;
            case TM_AFL_CLUB_GOLD_COAST :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","AFL Club App - Gold Coast"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","AFL Club App - Gold Coast"}));
                s_server = "AFL Club Android App";
                break;
            case TM_AFL_CLUB_HAWTHORN_HAWKS :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","AFL Club App - Hawthorn Hawks"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","AFL Club App - Hawthorn Hawks"}));
                s_server = "AFL Club Android App";
                break;
            case TM_AFL_CLUB_KANGAROOS :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","AFL Club App - Kangaroos"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","AFL Club App - Kangaroos"}));
                s_server = "AFL Club Android App";
                break;
            case TM_AFL_CLUB_MELBOURNE_DEMONS :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","AFL Club App - Melbourne Demons"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","AFL Club App - Melbourne Demons"}));
                s_server = "AFL Club Android App";
                break;
            case TM_AFL_CLUB_PORT_ADELAIDE :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","AFL Club App - Port Adelaide"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","AFL Club App - Port Adelaide"}));
                s_server = "AFL Club Android App";
                break;
            case TM_AFL_CLUB_RICHMOND_TIGERS :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","AFL Club App - Richmond Tigers"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","AFL Club App - Richmond Tigers"}));
                s_server = "AFL Club Android App";
                break;
            case TM_AFL_CLUB_STKILDA_SAINTS :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","AFL Club App - St.Kilda Saints"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","AFL Club App - St.Kilda Saints"}));
                s_server = "AFL Club Android App";
                break;
            case TM_AFL_CLUB_SYDNEY_SWANS :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","AFL Club App - Sydney Swans"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","AFL Club App - Sydney Swans"}));
                s_server = "AFL Club Android App";
                break;
            case TM_AFL_CLUB_WEST_COAST_EAGLES :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","AFL Club App - West Coast Eagles"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","AFL Club App - West Coast Eagles"}));
                s_server = "AFL Club Android App";
                break;
            case TM_AFL_CLUB_WESTERN_BULLDOGS :
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","AFL Club App - Western Bulldogs"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","AFL Club App - Western Bulldogs"}));
                s_server = "AFL Club Android App";
                break;
            // End AFL Clubs
            case TM_PUCK_REMOTE:
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"PUCK","TTVPlus"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"PUCK","TTVPlus"}));
                s_server = "PUCK TTVPlus Android App";
                break;
            case TM_MYFOOTBALL:
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","MYFOOTBALL"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","MyFootball"}));
                s_server = "MyFootball Android App";
                break;
            case TD_DEVICE_CARE:
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"TD","Service","DeviceCare"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"TD","Service","DeviceCare"}));
                s_server = "TD Service DeviceCare Android App";
                break;
            default:
                s_pPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","DEV"}));
                s_hPrefix = new ArrayList<String>(Arrays.asList(new String[] {"BM","Sport","DEV"}));
                s_server = "BM Dev Android App";
                break;
        }
    }

    private static String tmJoin(ArrayList<String> strList, String delimeter) {

        StringBuilder sb = new StringBuilder();
        String loopDelimeter = "";

        for(String s : strList) {

            sb.append(loopDelimeter);
            sb.append(s);

            loopDelimeter = delimeter;
        }

        return sb.toString();
    }
}