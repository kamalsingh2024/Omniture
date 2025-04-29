    function onYTStateChange(e) { 
 
  			var player = e.target;
			//full duration of video
			var duration = player.getDuration();
          	//current time of video
			var currentTime = player.getCurrentTime();
			//title
      		var yt_title = "YT:" + player.getVideoData().title;
			
			//Start of the video
			if (e.data == YT.PlayerState.PLAYING && e.data == 1) {
				_satellite.notify("Youtube start : " + youtubePlayerState(e.data) + " Youtube ID : " + yt_title)
				//Adobe Analytics video code
				s.Media.open(yt_title,duration,"TMHPYoutubeVideo");
				s.Media.play(yt_title,currentTime);
				//END of Adobe Analytics video code
				//Video started
				player.done=true;
			}
			
			//Play of video but not start of video
			if (e.data == YT.PlayerState.PLAYING && e.data == 1) {
				_satellite.notify("Youtube play : " + youtubePlayerState(e.data) + " Youtube ID : " + yt_title)
				//Adobe Analytics video code
				s.Media.play(yt_title,currentTime);
				//END of Adobe Analytics video code
			}
			
			//Video paused
			if (e.data == YT.PlayerState.PAUSED && e.data == 2) {
				_satellite.notify("Youtube pause: " + youtubePlayerState(e.data) + " Youtube ID : " + yt_title)
				//Adobe Analytics video code
				s.Media.stop(player.getVideoUrl(),currentTime);
				//END of Adobe Analytics video code
			}
			
			//Video Completed
			if (e.data == YT.PlayerState.ENDED) {
				_satellite.notify("Youtube completed: " + youtubePlayerState(e.data) + " Youtube ID : " + yt_title)
				//Adobe Analytics video code
				s.Media.stop(yt_title,currentTime);
				s.Media.close(yt_title);
				//END of Adobe Analytics video code
				//Video ended
				player.done = false;
			}
		}


		function youtubePlayerState(eventID){
			var state="";
			switch(eventID){
				case -1 : state="unstarted";
						  return state;
				case 0 : state="ended";
						  return state;
				case 1 : state="playing";
						  return state;
				case 2 : state="paused";
						  return state;
				case 3 : state="buffering";
						  return state;
				case 5 : state="video cued";
						  return state;	
				default : state="unknown";
						  return state;			  
			}
		
		}