/**
 * Simon Rumble <simon.rumble@team.telstra.com> 20101223
 */

// Comment out the following line when moving to production
s.un = 'telstrabpsamsungdev,telstrabpiptvdev';

// Uncomment the following line when moving to production
//s.un='telstrabpsamsungprd,telstrabpiptvprd';

// DO NOT EDIT BELOW THIS LINE

// Use samsungOmnitureBeacon() to write out all the Omniture stuff.
// samsungOmnitureBeacon(coding standard, unique box identifier, page hierarchy);
// samsungOmnitureBeacon(1, 'PBM3445X', 'Samsung|BigPond TV|Channel Listing|BigPond News');
function samsungOmnitureBeacon(codingStandardVersion, boxIdent, pageHierarchy){
	s.visitorID = sanitizeBoxIdent(boxIdent);
	
	s.pageName = '';
	s.hier1 = '';
	s.eVar24 = boxIdent;
	
	// Allow for changes in the coding standards
	switch (codingStandardVersion) {
		// Version 1 May 2010
		case 1:
			
			// Split out pageHierarchy into the appropriate props and vars
			pageHierarchy = pageHierarchy.split('|');
			var i;
			for (i = 0; i < pageHierarchy.length; i += 1) {
				switch (i) {
					case 0:
						s.prop1 = pageHierarchy[i];
						s.eVar1 = pageHierarchy[i];
						break;
					case 1:
						s.prop2 = pageHierarchy[i];
						s.eVar2 = pageHierarchy[i];
						break;
					case 2:
						s.prop3 = pageHierarchy[i];
						s.eVar3 = pageHierarchy[i];
						break;
					case 3:
						s.channel = pageHierarchy[i];
						s.eVar4 = pageHierarchy[i];
						break;
					case 4:
						s.prop4 = pageHierarchy[i];
						s.eVar5 = pageHierarchy[i];
						break;
					case 5:
						s.prop5 = pageHierarchy[i];
						s.eVar15 = pageHierarchy[i];
						break;
				}
				
				// Build up the hierarchy delimited by pipes
				if (i !== 0) 
					s.hier1 = s.hier1 + '|';
				s.hier1 = s.hier1 + pageHierarchy[i];
				
				if (i !== 0) 
					s.pageName = s.pageName + ':';
				s.pageName = s.pageName + pageHierarchy[i];
			}
			i++;
			break;
			
		// If no coding version, it must be coded at page level.
		default:
			break;
	}
	
	var s_code = s.t();
	if (s_code) {
		document.write(s_code);
	}
	s.manageVars("clearVars","visitorID", 2);

}

function samsungOmnitureVideoPerformance(videoId, eventType, startTime, boxIdent){
	s.visitorID = sanitizeBoxIdent(boxIdent);
	s.eVar24 = boxIdent;
	
	// Player variables
	s.prop14 = 'Samsung';
	s.eVar36 = s.prop14;
	// videoId variables
	s.eVar49 = videoId;
	s.prop15 = videoId;
	
	// This string is what gets sent to s.tl()
	var linkTrackString;
	
	// Get the time the function was called
	var time = (new Date()).getTime();
	
	// Depending on the eventType, do different things.
	switch (eventType) {
		case 'start':
			linkTrackString = 'Video start';
			s.events = 'event30';
			break;
			
		case 'firstFrame':
			linkTrackString = 'Video first frame';
			s.events = 'event31';
			s.eVar20 = time - startTime;
			break;
			
		case 'firstFrameAfterAdvert':
			linkTrackString = 'Video first frame between advert and video';
			s.events = 'event31,event34';
			s.eVar20 = time - startTime;
			break;
			
		case 'bufferUnderrun':
			linkTrackString = 'Video buffer underrun';
			s.events = 'event32';
			break;
			
		case 'firstFrameAfterUnderrun':
			linkTrackString = 'Video rebuffer first frame';
			s.events = 'event33';
			s.eVar20 = time - startTime;
	}
	// Round the time into 100ms
	if (s.eVar20) {
		s.eVar20 = Math.round(s.eVar20 / 100) * 100;
	}
	s.linkTrackVars = ('events,eVar24,eVar36,prop14,eVar49,prop15,eVar20');
	s.linkTrackEvents = ('event30,event31,event32,event33,event34');
	s.tl(this, 'o', linkTrackString);
	
	s.manageVars("clearVars","visitorID", 2);
	return time;
}

function samsungOmnitureVideoPerformanceLiveChannelBeacon(videoId, boxIdent){
	// Still just a stub
	s.visitorID = sanitizeBoxIdent(boxIdent);

	s.manageVars("clearVars");
	s.eVar24 = boxIdent;
	
	// Player variables
	s.prop14 = 'Samsung';
	s.eVar36 = s.prop14;
	
	// Create a string, rounded to the nearest five minutes, of the current date.
	var time = new Date();
	var roundedMins = (5*Math.round(time.getMinutes()/5));
	var dateString = time.getFullYear() + '-' + time.getMonth() + '-' + time.getDate() + ' ' + time.getHours() + ':' + roundedMins;
	
	// Set that into prop45 along with the player and video ID.
	s.linkTrackVars = 'prop45';
	s.prop45  = s.prop14 + '|' +  videoId + '|' + dateString;
	s.tl(this, 'o', 'Linear channel beacon: ' + videoId);
	s.manageVars("clearVars","visitorID", 2);
}

function samsungOmnitureEvent(codingStandardVersion, boxIdent, trackEvent){

	s.visitorID = sanitizeBoxIdent(boxIdent);
	s.manageVars("clearVars");
	s.eVar24 = boxIdent;
	
	// Allow for changes in the coding standards
	switch (codingStandardVersion) {
	// Version 1 May 2010
	case 1:
//		s.prop38 = trackEvent;
//		s.eVar47 = trackEvent;
//		s.events = "event14";
		s.tl(this, 'o', trackEvent);
	}
	s.manageVars("clearVars","visitorID", 2);
}
	

function sanitizeBoxIdent(boxIdent){
	return boxIdent.replace("-", "_");
}
