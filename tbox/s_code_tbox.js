// Global variable to hold our stuff
if (!BP) {
	var BP = {};
}

// Define the report suiteBP. Use development until approved to go live.
BP.reportsuites = 'telstrabptboxdev,telstrabpiptvdev';
//BP.reportsuites = 'telstrabptboxprd,telstrabpiptvprd';

// Don't edit below here

// This code re-implements a simplified version of Omniture's standard
// JavaScript library, to overcome the hardware limitations of the T-Box.
// It pulls the device MAC address using a Netgem-specific API, to use as
// the visitorID for Omniture.
//
// Available functions:
//   BP.reportingBeacon(codingVersion, hierarchy)
//   Example:
//      BP.reportingBeacon(1, 'T-Box|Apps|Games|Solitaire|default');
//
//   BP.Media
//   Example:
//      A typical session, where a user of "Test Player" opens "Test Video", which is
//      30 seconds long, plays the first ten seconds, then skips ahead to the 20 second mark
//      and watches to the end of the video.
//         BP.Media.open('Test Video', 30, 'Test player');
//         BP.Media.play(0);
//         BP.Media.stop(10);
//         BP.Media.play(20);
//         BP.Media.stop(30);
//         BP.Media.close();
//
// The core of the whole things is BP.sendBeacon(), which pulls in some
// boilerplate items like the MAC address, then constructs an Omniture
// beacon by iterating over the BP.s object and inserting the objects
// beneath that as name=value pairs.

// Reporting beacon sends data to Omniture for Page Views.
// Usage:
// BP.reportingBeacon(1, 'T-Box|Apps|Games|Solitaire|default');
BP.reportingBeacon = function (codingVersion, hierarchy){
	BP.s = {};
	
	if (codingVersion === 1) {
		// Split out pageHierarchy into the appropriate props and eVars
		BP.hierarchy = hierarchy.split('|');
		var i;
		for (i = 0; i < BP.hierarchy.length; i += 1) {
			switch (i) {
				case 0:
					BP.s.c1 = BP.hierarchy[i];
					BP.s.v1 = BP.hierarchy[i];
					break;
				case 1:
					BP.s.c2 = BP.hierarchy[i];
					BP.s.v2 = BP.hierarchy[i];
					break;
				case 2:
					BP.s.c3 = BP.hierarchy[i];
					BP.s.v3 = BP.hierarchy[i];
					break;
				case 3:
					BP.s.ch = BP.hierarchy[i];
					BP.s.v4 = BP.hierarchy[i];
					break;
				case 4:
					BP.s.c4 = BP.hierarchy[i];
					BP.s.v5 = BP.hierarchy[i];
					break;
				case 5:
					BP.s.c5 = BP.hierarchy[i];
					BP.s.v15 = BP.hierarchy[i];
					break;
			}
			
			if (BP.s.h1 === undefined) {
				BP.s.h1 = '';
			}
			// Build up the hierarchy delimited by pipes
			if (i !== 0) {
				BP.s.h1 = BP.s.h1 + '|';
			}
			BP.s.h1 = BP.s.h1 + BP.hierarchy[i];
			if (BP.s.pageName === undefined) {
				BP.s.pageName = '';
			}
			if (i !== 0) {
				BP.s.pageName = BP.s.pageName + ':';
			}
			BP.s.pageName = BP.s.pageName + BP.hierarchy[i];
		}
		if (BP.searchTerm) {
			BP.s.v22 = 'T-Box: ' + BP.searchTerm;
		}
		
		if (BP.slideShowTime) {
			BP.s.v39 = 'T-Box Slideshow: ' + BP.slideShowTime;
		}

		// Now send that sucker
		BP.sendBeacon('pageView');
		
		// Wipe variables
		BP.searchTerm = '';
		BP.slideShowTime = '';
	}
};

// Sends custom link actions (pev2) to Omniture.
// Usage:
// BP.reportingBeaconLink(1, 'My Action');
BP.reportingBeaconLink = function(codingVersion, action){
	BP.s = {};
	if (codingVersion === 1) {
		BP.s.pe= 'lnk_o';
		BP.s.pev2 = action;
	}
	BP.sendBeacon('customLink');
}

// Recreating Omniture s.Media() library, with added support for our own
// performance reporting.

BP.Media = {};
BP.Media.open = function (videoId, duration, player) {
	BP.Media.startTime = BP.timeSeconds();
	BP.Media.duration = duration;
	BP.Media.videoId = videoId;
	BP.Media.player = player;
	BP.Media.totalSeconds = 0;
	BP.s = {};
	BP.s.pe = 'm_s';
	BP.s.pev3 = BP.Media.videoId + '--**--' + BP.Media.duration + '--**--' + BP.Media.player + '--**--0--**--' + BP.Media.startTime + '--**--S0L0';
	BP.sendBeacon('video');
	BP.s = {};
	BP.Media.session = '';
}

BP.Media.play = function (offset) {
	// Make the session "L" if this is the first one after BP.Media.open()
	if (BP.Media.session) {
		BP.Media.session += 'S' + offset;
	}
	else {
		BP.Media.session += 'L' + offset;
	}
	BP.Media.playOffset = offset;
}

BP.Media.stop = function (offset) {
	BP.Media.session += 'E' + offset;
	BP.Media.totalSeconds += (offset - BP.Media.playOffset);
	BP.Media.playOffset = '';
}

BP.Media.close = function () {
	BP.s = {};
	BP.s.pe = 'm_o';
	BP.s.pev3 = BP.Media.videoId + '--**--' + BP.Media.duration + '--**--' + BP.Media.player + '--**--' + BP.Media.totalSeconds + '--**--' + BP.Media.startTime + '--**--' + BP.Media.session; 
	BP.sendBeacon('video');
	BP.s = {};
};

BP.sendBeacon = function (beaconType) {
	// T-Box MAC address
	try {
		if (Netgem.applications.main.macAddress()) {
			BP.macAddress = Netgem.applications.main.macAddress();
			BP.macAddress = BP.macAddress.replace(/:/g, '');
			BP.macAddress = BP.macAddress.toLowerCase();
			BP.s.vid = BP.macAddress;
			BP.s.v24 = BP.s.vid;
		}
	}
	catch (e) {
		BP.s.v24 = 'No MAC address: ' + e;
	}

	// Protocol and secure/non-secure server
	if (document.protocol === 'https') {
		BP.imageUrl = 'https://' + BP.trackingServerSecure;
	} else {
		BP.imageUrl = 'http://' + BP.trackingServer;
	}
	
	// Boilerplate bits
	BP.imageUrl = BP.imageUrl + '/b/ss/' + BP.reportsuites + '/1/' + BP.codingVersion + '/s' + Math.floor(Math.random()*10000000000000) + '?AQB=1&ndh=1&ns=' + BP.visitorNamespace + '&cdp=' + BP.cookieDomainPeriods;
	
	// Go through contents of BP.s object and add as URL-encoded name=attribute
	for (name in BP.s) {
		BP.imageUrl += '&' + name + '=' + escape(BP.s[name]);
	}
	
	// Boilerplate ending
	BP.imageUrl = BP.imageUrl + '&AQE=1';
	
	// Insert the image tag to the end of <body>
	var tag = document.createElement('img');
	tag.style.cssText = 'display:none;';
	tag.src = BP.imageUrl;
	document.getElementsByTagName('body')[0].appendChild(tag);
	//document.write('<p>' + unescape(tag.src) + '</p>');
	
	// Clear variables
	BP.imageUrl = '';
	BP.s = '';
}

if (window.location.host.indexOf(".com.au") != -1) {
	BP.cookieDomainPeriods = "3";
} else {
	BP.cookieDomainPeriods = "2";
}
BP.visitorNamespace = "bigpond";
BP.trackingServer = "info.telstra.com";
BP.trackingServerSecure = "info.telstra.com";

// Coding version is reported to Omniture for their debugging purposes, though apparently they don't use it
BP.codingVersion = 'BP.0.4';

BP.timeSeconds = function () {
	return Math.round((new Date).getTime() / 1000);
}
