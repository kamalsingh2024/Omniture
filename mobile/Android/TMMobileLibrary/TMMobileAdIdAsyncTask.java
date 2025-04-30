package com.telstra.tm.android;

import android.os.AsyncTask;
import android.content.Context;
import com.google.android.gms.ads.identifier.AdvertisingIdClient;
import com.google.android.gms.ads.identifier.AdvertisingIdClient.Info;
//import com.google.android.gms.common.GooglePlayServicesAvailabilityException;
import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.common.GooglePlayServicesRepairableException;
import java.io.IOException;
import java.util.HashMap;

/**
 * Created by deyuwang on 19/2/18.
 */

public class TMMobileAdIdAsyncTask extends AsyncTask<HashMap<String, Object>, Void, Boolean> {

    private final Context mContext;

    public TMMobileAdIdAsyncTask(final Context context) {
        mContext = context;
    }

    @Override
    protected void onPreExecute() {
        super.onPreExecute();

    }

    @Override
    protected Boolean doInBackground(HashMap<String, Object>... s_basicData) {
        /** Retrieve the Android Advertising Id
         *
         * The device must be KitKat (4.4)+
         * This method must be invoked from a background thread.
         *
         * */

        Info adInfo = null;
        try {
            adInfo = AdvertisingIdClient.getAdvertisingIdInfo(mContext);

        } catch (IOException e) {
            // Unrecoverable error connecting to Google Play services (e.g.,
            // the old version of the service doesn't support getting AdvertisingId).
            e.printStackTrace();
        //} catch (GooglePlayServicesAvailabilityException e) {
            // Encountered a recoverable error connecting to Google Play services.
            return false;
        } catch (GooglePlayServicesNotAvailableException e) {
            // Google Play services is not available entirely.
            return false;
        }catch (GooglePlayServicesRepairableException e) {
            e.printStackTrace();
            return false;
        }
        try{
            final String id = adInfo.getId();
            s_basicData[0].put("device.adid", id);
        }catch (NullPointerException e){
            e.printStackTrace();
        }
        //final boolean isLAT = adInfo.isLimitAdTrackingEnabled();
        return true;
    }

    protected void onPostExecute(Boolean result) {

    }
}
