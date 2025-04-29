/*	This file is the top half of our s_code.js file. It will be minified, with
	whitespace and comments stripped out, then concatenated with the Omniture-supplied
	component, s_code_src_bottom.js, which is already compressed and obfuscated so we
	don't mess with it.

	Build this with "build.bat" in the top level of the SVN repository
	See http://wiki.in.telstra.com.au/display/tls/s_code+build+system
*/

/* Kampyle:  Integration configuration settings */
window.k_sc_param = window.k_sc_param || {
    version: 1.1
};

/*
	Create a BP namespace object, without overwriting one that already exists.
	We'll keep all our stuff nicely hidden in here.
*/
var BP_SC = BP_SC || {};

/*
	Default accounts. Override with s.un
*/
var s_account = "telstrabpbigpondprd";

/*
	Creates the s object
*/
var s = s_gi(s_account);

/*
	Two periods (full stops) in domain names. This is problematic since we share .com and .com.au
	domains. e.g., bigpond.com has only one period, www.afl.com.au has three.
*/
s.cookieDomainPeriods = '3';

/*
	We get around the above problem with an if statement:
*/
if (window.location.host.indexOf(".com.au") != -1) {
	s.cookieDomainPeriods = "3";
} else {
	s.cookieDomainPeriods = "2";
}

/*
	Daylight saving start/end dates mm/dd/yy
*/
 s.dstStart = "10/01/2017";
 s.dstEnd = "04/01/2018";

/*
	Not quite sure why but this is grabbing the year.
*/
var tDate = new Date();
s.currentYear = tDate.getFullYear();

/*
	Tracks external links and links for downloads by adding an onClick event handler to links identified as being
	external or downloads.  External links are links to any domain that doesn't match s.linkInternalFilters
	Downloads are identified as URLs that end with the extensions lists in s.linkDownloadFileTypes
*/
s.trackDownloadLinks = true;
s.trackExternalLinks = true;

/*
	ClickMap-related, Dynamic Object Detection
*/
s.trackInlineStats = true;

/*
	The list of file extensions considered to be downloads in s.trackDownloadLinks
*/
s.linkDownloadFileTypes = "exe,zip,wav,mp3,mov,mpg,avi,wmv,pdf,doc,docx,xls,xlsx,ppt,pptx";

/*
	The list of domain names considered "internal" and so not tracked by s.trackExternalLinks.
*/
s.linkInternalFilters="javascript:,1seven.com.au,nmfchospitality.com.au,hfccorporatehospitality.com.au,weflyasone.afc.com.au,19thman.com.au,northernriverinafnl.com.au,membership.lions.com.au,membership.carltonfc.com.au,membership.collingwoodfc.com.au,membership.essendonfc.com.au,membership.fremantlefc.com.au,membership.geelongcats.com.au,membership.gwsgiants.com.au,membership.hawthornfc.com.au,membership.melbournefc.com.au,membership.nmfc.com.au,weareportadelaide.com.au,afl9s.spawtz.com,membership.richmondfc.com.au,saintsmembership.com.au,membership.sydneyswans.com.au,membership.westcoasteagles.com.au,rloc.com.au,bigpondmovies.com,19thman.com.au,womens.afl,membership.westernbulldogs.com.au,rabbitohs.com.au,events.wce.com.au,lookingafterme.org.au,tixstar.com.au/s/afl,adelaidefilmfestival.org,afl.com.au,afl.footytips.com.au,smarter.telstra.com.au,aflwtipping.afl,afl.footytips.com.au,afl.virtualsports.com.au,aflmembership.com.au,anz-championship.com,aus.wwte8.com/pub/agent.dll,australianmasters.com.au,insideportadelaide.com.au,basic.messaging.bigpond.com,bbfdr.ticketek.com.au,beeneverywhere.com.au,bigblog.com.au,bigpond.cruises.com.au,bigpond.domain.com.au,bigpond.homepriceguide.com.au,catchphrasecup.com.au,bigpond.open.edu.au,bigpond.raisingchildren.net.au,bigpondeverest.com,bigpondgames.com,bigpondkids.com,bigpondmovies.com.au,bigpondmusic.com,bigpondnews.com,bigpondoffice.com.au,bigpondphotos.com,bigpondphotos.com.au,bigpondpilot.com.au,bigpondsecurity.com,bigpondshopping.com,bigpondsitehelp.com,bigpondsitehelp.com,bigpondsmsoffers.com.au,bigpondsport.com,bigpondsport.com.au,bigpondtelstrasearch.com,bigpondtickets.ticketek.com.au,bigpondtravel.com,bigpondtravel.com.au,bigpondtv.com,bigpondvideo.com,bigpondvideo.com.au,bluesfc.com.au,bombersfc.com.au,afleventoffice.com.au,bpplanfinder.com,broncos.com.au,bulldogs.com.au,carltonfc.com.au,carltonfc.footytips.com.au,catsfc.com.au,centenaryofrugbyleague.com.au,christmas.bigpond.com,collingwoodfc.com.au,cowboys.com.au,ctones.telstra.com,downloads.bigpondmovies.com,dragons.com.au,dreamteam.nrl.com,dreamteam.nrl.com,dreamteampro.virtualsports.com.au,dvd.bigpondmovies.com,files.bigpond.com,files.bigpond.com,fremantlefc.com.au,gamearena.com.au,gamenow.com.au,geelongcats.com.au,gfc.com.au,girlfriday.tv,go.bigpond.com,goldcoastfc.com.au,hawthornfc.com,hawthornfc.com.au,bluesfoundation.org.au,hm.bigpond.com,hm.bigpondnews.com,horseracing.bigpond.com,horseracing.bigpondsport.com,iad.bigpondvideo.com,kangaroos.com.au,lions.com.au,magpiesfc.com.au,manlyseaeagles.com.au,melbournefc.com.au,melbournestorm.com.au,memberoffers.bigpond.com,messaging.bigpond.com,mobilefun.telstra.com,myacct.bigpond.com,newcastleknights.com.au,newzealandwarriors.co.nz,newzealandwarriors.com.au,nrl.com,nrl.com.au,nrl.virtualsports.com.au,nrlfinals.virtualsports.com.au,nrlwarriors.com,nswrl.com.au,parraeels.com.au,penrithpanthers.com.au,planetteal.com.au,portadelaidefc.com.au,portadelaidefc.footytips.com.au,portpowerfc.com.au,promo.bigpond.com,qrl.com.au,raiders.com.au,richmondfc.com.au,saints.com.au,say.bigpond.com,search.api.bigpond.com,sharks.com.au,shop.bigpond.com,shop.bigpondgames.com,signon.bigpond.com,storage.bigpond.com,sydneyroosters.com.au,sydneyswans.com.au,sydneysymphony.bigpondmusic.com,telstra.com,thenews.bigpond.com,thewarriors.co.nz,thewarriors.com.au,thub.bigpond.com,tipping.afl.com.au,tipping.nrl.com,titans.com.au,westcoasteagles.com.au,150years.com.au,afl.virtualsports.com.au,bigpond.custhelp.com,bigpondguide.com,westcoasteagles.footytips.com.au,westernbulldogs.com.au,weststigers.com.au,deezone.com.au,itsyourcall.afl.com.au,lifestylefood.com.au,lifestyle.com.au,skynews.com.au,racingnetwork.com.au,giantsacademy.com.au,sportsfan.com.au,tradingpost.com.au,carshowroom.com.au,aflmedia.championdata.com,tickets.nrl.com,play.afl,airg.com,.airg.com,fantasy.afl.com.au,essendonfc.com.au,m.essendonfc.com.au,m.afc.com.au,afc.com.au,m.hawthornfc.com.au,m.richmondfc.com.au,m.collingwoodfc.com.au,m.geelongcats.com.au,matchups.afl.com.au,m.sydneyswans.com.au,m.westernbulldogs.com.au,m.portadelaidefc.com.au,m.westcoasteagles.com.au,m.carltonfc.com.au,m.melbournefc.com.au,nmfc.com.au,m.fremantlefc.com.au,m.saints.com.au,m.lions.com.au,id.afl.com.au,gwsgiants.com.au,m.nmfc.com.au,m.gwsgiants.com.au,membership.afl.com.au,allaustralian.afl.com.au,goaloftheyear.afl,markoftheyear.afl,m.goldcoastfc.com.au,subscription.afl.com.au,aflschoolstipping.com.au,fansmvp.afl.com.au,tipping.portadelaidefc.com.au,tipping.collingwoodfc.com.au,tipping.hawthornfc.com.au,tipping.fremantlefc.com.au,tipping.afc.com.au,tipping.westcoasteagles.com.au,tipping.richmondfc.com.au,tipping.nmfc.com.au,tipping.essendonfc.com.au,tipping.saints.com.au,tipping.gwsgiants.com.au,tipping.carltonfc.com.au,tipping.lions.com.au,lionshospitality.com.au,sydneyswanshospitality.com.au,.nmfc.com.au,testafl.com,aflmedia.net";

BP_SC.linkInternalFilters = s.linkInternalFilters;

/*
	If set to "false", truncates the querystring from reports where you hover over the page name
	and see the URL. Should be set to "true" for sites where the querystring is significant
*/
s.linkLeaveQueryString = false;

/*
	You can have the s_code fire off custom links on certain conditions.
*/
s.linkTrackVars = "None";
s.linkTrackEvents = "None";

/*
	At the point where s.t() or s.tl() is called, run the s_doPlugins() function.
*/
s.usePlugins = true;

/*
	This stuff runs when s.t() or s.tl() is called, and gives you the opportunity to detect and vary things
	set at the page level.
*/
function s_doPlugins(s) {
	/*
		Override the dodgy internal link domains in some of the site_specific_code.js files, particularly AFL
	*/	
	if (s.linkInternalFilters !== BP_SC.linkInternalFilters) {
		s.linkInternalFilters = BP_SC.linkInternalFilters;
	}

	/*
		Test and Target gubbins
	*/	
	s.tnt = s.trackTNT();
	s.events = s.apl(s.events, "event27", ",", 1);

	/*
		eVar7, Internal Campaign, is the contents of a querystring parameter named "cid"
	*/	
	if (s.getQueryParam('cid')) {
		s.eVar7 = s.getQueryParam('cid');
	}

	/*
		Dunno but it's eVar8 which is BP external campaigns
	*/	
	if (s.getQueryParam('sssdmh')) {
		s.eVar8 = s.getValOnce(s.getQueryParam('sssdmh'), 'sssdmhmp_cookie', 1);
		s.eVar45 = s.getQueryParam('dmid');
	} else if (s.getQueryParam('pid')) {
		s.eVar8 = s.getValOnce(s.getQueryParam('pid'), 'pmp_cookie', 1);
		s.clickThruQuality('pid', 'event25', 'event26');
	}
	
	/*
		eVar13 and prop47, Intra-Site Campaign is the contents of querystring parameter "ref"
	*/	
	if (s.getQueryParam('ref')) {
		s.eVar13 = s.getQueryParam('ref');
		s.prop47 = s.getQueryParam('ref');
	}

	/*
		Dunno?  We (BP) use that eVar for Article Name; yep going to take this out
	*/
	//s.eVar34 = s.getValOnce(s.getQueryParam('msgnm'), 'msgnm_cookie', 1);
	
	/*
		Google Content Placement?
	*/
	s.eVar39 = s.getValOnce(s.getQueryParam('gcid'), 'gcmp_cookie', 1);

	/*
		Dunno? BP don't have this eVar defined
	*/
	s.eVar49 = s.getValOnce(s.getQueryParam('track_id'), 'rmp_cookie', 1);

	/*	
		Dunno? BP uses this for "Last site" or as it used to be known "Home page referrals".

	*/
	if (s.getQueryParam('sio')) {
		s.eVar26 = s.getValOnce(s.getQueryParam('sio'), 'smp_cookie', 1);
	}

	/*
		Dunno? Something to do with the click through quality plugin?
	*/	
	if (s.getQueryParam('s_kwcid')) {
		s.pageURL = s.manageQueryParam('s_kwcid', 0, 1);
		s.eVar8 = s.getValOnce(s.getQueryParam('s_kwcid'), 'pmp_cookie', 1);
		s.clickThruQuality('s_kwcid', 'event25', 'event26');
	}
	
	if (window.s_postPlugins) {
		s_postPlugins(s);
	}
	
	/*
		Time parting stuff.
	*/	
	s.prop33 = s.getTimeParting('h', '+10');
	s.prop34 = s.getTimeParting('d', '+10');
	s.prop35 = s.getTimeParting('w', '+10');
	s.eVar40 = s.getTimeParting('h', '+10');
	s.eVar41 = s.getTimeParting('d', '+10');
	s.eVar42 = s.getTimeParting('w', '+10');
	s.prop46 = s.getNewRepeat();
	s.eVar46 = s.getNewRepeat();
	
	/*
		Dunno? Seems to be attempting to record previous pageName and previous site, but this would
		only work within the same domain due to cookie cross-domain restrictions.
	*/
	if (s.pageName != ""){
	s.prop48 = s.getPreviousValue(s.pageName, 'gpv_e48', '');
	s.eVar43 = s.getPreviousValue(s.pageName, 'gpv_p43', '');
	}
	if (s.prop3 != ""){
	s.prop49 = s.getPreviousValue(s.prop3, 'gpv_p49', '');
	}
	if (s.eVar3 != ""){
	s.eVar44 = s.getPreviousValue(s.eVar3, 'gpv_e44', '');
    }
    // get page % viewed value
	if (s.pageName != ""){
	var ppv = s.getPercentPageViewed(s.pageName); //get array of data on prev page % viewed
	if( ppv && typeof ppv=='object' && ppv[0] == s.prop48 ) { //if ppv array returned and prev page id matches prev page name
  		s.prop16 = ppv[1] + '|' + ppv[2]; //prop22: prev page max and initial % viewed, delimited by "|". (Use classifications to separate values)
		}
	}
	/*
		Campaign stacking of eVar8 (BP External campaign)
		Cross-site cookies mean this would be stacked only for the specific site, but that's
		probably desirable.
	*/
	s.eVar18 = s.crossVisitParticipation(s.eVar8, 's_evar18', '30', '10', '>', '');

	/*
		Dunno? Another thing using the click through quality.
	*/

	s.clickThruQuality('pid', 'event25', 'event26');

	/*
		For all BP sites that are not signup, record the last site that was visited.
		When a signup is recorded, this is used as the "access pull through" metric.
	*/
	if (s.prop3 !== 'BP_SC.com' && s.prop3 !== undefined && s.prop3 !== 'Internet') {
		s.eVar26 = s.prop3;
	}
			
	/*
		Track SSL vs non-SSL requests to be able to work out the load on our servers
		for s_code.js.
			event40 = SSL
			event41 = non-SSL
	*/
	if (document.location.protocol === 'https:') {
		s.events=s.apl(s.events,"event40",",",1);
	} else {
		s.events=s.apl(s.events,"event41",",",1);
	}

	/*
		Weather s.pageName is messed up.
	*/
	if (s.pageName === 'BP|News|Weather|Current:Home') {
		s.pageName = 'BP:News:Weather:Current:Home'
	}

	/*
		Telstra Retail campaign, also copied into the retail report suite
	*/
	
	if (s.getQueryParam('tc')) {
		s.eVar8 = s.getValOnce(s.getQueryParam('tc'), 'pmp_cookie', 1);
		s.clickThruQuality('tc', 'event25', 'event26');
		BP_SC.datCreateOmnitureBeacon('', s.getQueryParam('tc'));
	}
	
	if (typeof(s.hier1) !== 'undefined') {
		BP_SC.hierarchy = s.hier1.split('|');
		switch (BP_SC.hierarchy[2]) {
			case "Health":
			BP_SC.addReportSuite('telstrabphealth');
			break;
		}
	}

	 //add page name for videos tracking
	 s.contextData['pageName'] = s.pageName;
     // AAM segment to AA
	 s.list1 = getDatCookie('aamtd_targettm');
     
	 var reportSuites = s.un.split(',');
	/* Add in the Telstra Global report suite, only if we have production data*/
	var reportSuites = s.un.split(',');
	reportSuites.reverse();
	if(reportSuites.indexOf("telstraglobalprd") == -1 && s.un.indexOf("prd") > 0) {
		reportSuites.push("telstraglobalprd");
		}
	s.un = reportSuites.join(',');
	/*
		Move the login pages to reside under "Portal" as they are considered part of the home page, per
		Tracy Grimson request 2014-01-22.
	*/
	if (s.hier1 === 'BP|Services|RAA|DefaultLogin') {
		s.hier1 = 'BP|Portal|Login';
		s.pageName = 'BP|Login';
		s.prop2 = s.eVar2 = 'Portal';
		s.prop3 = s.eVar3 = 'Login';
		s.channel = s.eVar4 = '';
	}/* fix for NRL ditital pass code issue*/
	if (s.hier1 === 'BP|Sport|NRL|NRL.com|DigitalPass|DigitalPass Voucher ') {
		s.hier1 = 'BP|Sport|NRL|NRL.com|DigitalPass|Marketing';
		s.pageName = 'BP:NRL:NRL.com:DigitalPass:Marketing';
		s.prop1 = 'BP';
    	s.prop2 = 'Sport';
    	s.prop3 = 'NRL';
    	s.channel = "NRL.com";
    	s.prop4 = "DigitalPass";
    	s.prop5 = "Marketing";
    	s.eVar1 = s.prop1;
    	s.eVar2 = s.prop2;
    	s.eVar3 = s.prop3;
    	s.eVar4 = s.channel;
    	s.eVar5 = s.prop4;
    	s.eVar15 = s.prop5;
    	}
}

/*
	Run the plugins.
*/
s.doPlugins = s_doPlugins;

BP_SC.datCreateOmnitureBeacon = function(events, campaign) {
	var prefix = 'https://infos.telstra.com/b/ss/telstratdretailprd/1/H.27.5/';
	prefix += parseInt(Math.random()*9999999999,10);
	prefix += '?AQB=1&ndh=1&ns=telstracorporation&cdp=3';
	var suffix = '&g=' + escape(document.location.href) + '&c8=D%3Dg&AQE=1';
	if (events) {
		events = '&events=' + escape(events);
	} else {
		events = '';
	}
	if (campaign) {
		campaign = '&v0=' + escape(campaign);
	} else {
		campaign = '';
	}
	var beaconUrl = prefix + events + campaign + suffix;
	BP_SC.datAdServer('<img height="1" width="1" style="border-style:none;" alt="" src="' + beaconUrl + '" alt="" />');
};

/*
	Function to check if a report suite already exists in the s.un string and, if not,
	adds the appropriate report suite (prd or dev) based on the value of the BP report suite
*/
BP_SC.addReportSuite = function (rsidStem) {
	if ((s.un.search(/rsidStem/) === -1) && (s_account.search(/rsidStem/) === -1)) {
		if ((s.un.search(/telstrabpbigpondprd/) !== -1) || (s_account.search(/telstrabpbigpondprd/) !== -1)) {
			var rsidType = 'prd';
		} else {
			var rsidType = 'dev';
		}
		s.un = s.un + ',' + rsidStem + rsidType;
	}
}

/*
	Below this is Omniture's obfuscated gumpf. Don't mess with this. Don't minify.
*/
