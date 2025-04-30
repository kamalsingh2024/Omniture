package com.telstra.tm.android;

import android.os.AsyncTask;
import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.HashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by deyuwang on 25/02/2016.
 */
public class TMMobileCPTAsyncTask extends AsyncTask<HashMap<String, Object>, Void, Boolean> {


    @Override
    protected void onPreExecute() {
        super.onPreExecute();

    }

    @Override
    protected Boolean doInBackground(HashMap<String, Object>... s_basicData) {
        URL url;
        HttpURLConnection urlConnection = null;
        try {
            url = new URL("http://medrx.telstra.com.au/online.php");

            urlConnection = (HttpURLConnection) url.openConnection();
            TMMobile.tmSetIsTelstra(0); // set isTelstra to false before processing
            int responseCode = urlConnection.getResponseCode();
            if (responseCode == 200) {

                InputStream is = new BufferedInputStream(urlConnection.getInputStream());
                BufferedReader in = new BufferedReader(new InputStreamReader(is, "UTF-8"));

                String inputLine;
                StringBuffer answer = new StringBuffer(2000);

                while ((inputLine = in.readLine()) != null) {
                    answer.append(inputLine);
                    answer.append("\n");
                }
                in.close();

                String cptWholeStr = answer.toString();
                Pattern cptWholePtr = Pattern.compile("extraAdCallInfo = '(.*)'");
                Matcher matcher = cptWholePtr.matcher(cptWholeStr);
                if (matcher.find()) {
                    s_basicData[0].put("user.cpt", matcher.group(1));
                }

                Pattern hashIdPtr = Pattern.compile("cn=([[a-z][A-Z][0-9]]{16});");
                Matcher hashIdmatcher = hashIdPtr.matcher(cptWholeStr);
                if (hashIdmatcher.find()) {
                    s_basicData[0].put("user.hashId", hashIdmatcher.group(1));
                    TMMobile.tmSetIsTelstra(1);
                }

                Pattern uidPtr = Pattern.compile("po=([0-9]{10})'");
                Matcher uidMatcher = uidPtr.matcher(cptWholeStr);
                if (uidMatcher.find()) {
                    s_basicData[0].put("user.muid", uidMatcher.group(1));
                    TMMobile.tmSetIsTelstraMobile(true);
                }
                return true;
            }
        } catch(IOException e) {
            e.printStackTrace();
        } finally {
            urlConnection.disconnect();
        }

        return false;
    }

    protected void onPostExecute(Boolean result) {

    }
}
