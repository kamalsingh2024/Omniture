/**
 * (c) 2013 Adobe Systems Incorporated. All Rights Reserved.
 */

package com.adobe.adbmobilesamples;


//import android.media.MediaPlayer;

import android.os.Bundle;
import android.view.Window;

import com.adobe.mobile.Config;
import com.adobe.mobile.Media;
import com.adobe.mobile.MediaSettings;
import com.brightcove.player.edge.Catalog;
import com.brightcove.player.edge.VideoListener;
import com.brightcove.player.event.Event;
import com.brightcove.player.event.EventEmitter;
import com.brightcove.player.event.EventListener;
import com.brightcove.player.event.EventType;
import com.brightcove.player.logging.Log;
import com.brightcove.player.model.Video;
import com.brightcove.player.view.BrightcoveExoPlayerVideoView;
import com.brightcove.player.view.BrightcovePlayer;
import com.telstra.tm.android.TMMobile;


public class VideoPlayerActivity extends BrightcovePlayer {

	private EventEmitter eventEmitter;
	private MediaSettings settings;

	private String kViewControllerPlaybackServicePolicyKey = "BCpkADawqM2oRT4bpKZLwbcYPruSIUwl1sK8tn2gkKWGzNhootPqAk69qrwOT6eP9-yO50sPCQQpPpHWrGd5pLn0sNFkhTPqJ5JeVCMnpyAzvitvdtq0k6ddZFFFJssi4KZDn_Ty2zbZQneI";
	private String kViewControllerAccountID = "6076300361001";
	private String kViewControllerVideoID = "6088900645001";
	private String MEDIA_NAME;
	private double curPos=0;
	private boolean isClosed=false;

	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.video_player);
		brightcoveVideoView = (BrightcoveExoPlayerVideoView) findViewById(R.id.brightcove_video_view);

		eventEmitter = brightcoveVideoView.getEventEmitter();

		//eventEmitter.

		setupOmniture();

		Catalog catalog = new Catalog(eventEmitter, kViewControllerAccountID, kViewControllerPlaybackServicePolicyKey);

		catalog.findVideoByID((kViewControllerVideoID), new VideoListener() {

			// Add the video found to the queue with add().
			// Start playback of the video with start().
			@Override
			public void onVideo(Video video) {
				Log.i(TAG, "++++++ onVideo: video = " + video);
				brightcoveVideoView.add(video);

				/*
				 * Adobe Tracking - Media
				 *
				 * create our media settings object so we can configure our tracking preferences
				 */
				settings = TMMobile.tmConfigureVODTracking(video.getName(), video.getDuration()/1000, "AFLW", "AFLW Home");
				MEDIA_NAME = video.getName();
				/*
				 * Adobe Tracking - Media
				 *
				 * opens the media item, preparing it for tracking
				 */
				Media.open(settings,null);

				brightcoveVideoView.start();

			}

		});
	}

	private void setupOmniture() {

		eventEmitter.on(EventType.ANY, new EventListener() {
			@Override
			public void processEvent(Event event) {
				curPos = brightcoveVideoView.getCurrentPosition()/1000;
				//log all events
				Log.i(TAG, "++++onVideo: video = " + event.getType() + " - curPos="+curPos);

				switch (event.getType()){
					case EventType.PLAY:// video started
						if(!isClosed) {
							Media.play(MEDIA_NAME, curPos);
						}
						else{ //open new media tracking session if user got to the end decided to play video again
							Media.open(settings,null);
							Media.play(MEDIA_NAME, curPos);
							isClosed=false;
						}

						break;
					case EventType.PAUSE://video paused
						Media.stop(MEDIA_NAME,curPos);

						break;
					case EventType.COMPLETED://video ended
						Media.stop(MEDIA_NAME,curPos);
						Media.close(MEDIA_NAME);
						isClosed=true;

						break;
					case EventType.SEEKBAR_DRAGGING_PROGRESS: //seeking
						Media.stop(MEDIA_NAME,curPos);

						break;
					case EventType.SEEK_TO://seeked
						Media.play(MEDIA_NAME,curPos);

						break;
					case EventType.ANY:
						//do nothing

						break;
				}

			}
		});

	}



		@Override
	protected void onPause() {
		super.onPause();
		/*
		 * Adobe Tracking - Config
		 *
		 * call pauseCollectingLifecycleData() in case leaving this activity also means leaving the app
		 * must be in the onPause() of every activity in your app
		 */
		Config.pauseCollectingLifecycleData();

        /*
		 * Adobe Tracking - Media
		 *
		 * closes the media item
		 * media item should receive no more calls unless its a new open and play
		 */
        Media.close(MEDIA_NAME);
	}

	@Override
	protected void onResume() {
		super.onResume();
		/*
		 * Adobe Tracking - Config
		 *
		 * call collectLifecycleData() to begin collecting lifecycle data
		 * must be in the onResume() of every activity in your app
		 */
		TMMobile.tmCollectLifecycleData(this);
	}
}
