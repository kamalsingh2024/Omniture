// Comment out the following line when moving to production
s.un='telstrabpthubdev';

// Uncomment the following line when moving to production
//s.un='telstrabpthubprd';

// Use tHubOmnitureBeacon() to write out all the Omniture stuff.
// Usage example:
//	codingStandardVersion = 1;
//	pageHierarchy = "BP|Lifestyle|Health|Guy Leech Fitness|T-Hub ActiveZone|default";
//	tHubOmnitureBeacon(codingStandardVersion, pageHierarchy);
function tHubOmnitureBeacon(codingStandardVersion, pageHierarchy) {


	// Allow for changes in the coding standards
	switch(codingStandardVersion) {
		// Version 1 March 2010
		case 1:

		// Use Omniture's s.manageVars() to clear all the variables we set here.
		// If using AJAX methods where the page isn't re-loaded, you should do this
		// for ALL Omniture variables using:
		// s.manageVars("clearVars")
		s.manageVars("clearVars");

		// Split out pageHierarchy into the appropriate props and vars
		pageHierarchy = pageHierarchy.split('|');
		if ((pageHierarchy[3] === 'News' || pageHierarchy[3] === 'Video') && (pageHierarchy[2] === 'AFL' || pageHierarchy[2] === 'NRL') && !pageHierarchy[4]) {
			pageHierarchy.push('default');
		}

		if ((pageHierarchy[2] === 'EPG') && (pageHierarchy[3] === 'BPTV')) {
			pageHierarchy[2] = 'BPTV';
			pageHierarchy[3] = 'EPG';
		}

		var i;
		for (i=0; i < pageHierarchy.length; i += 1) {
			switch(i) {
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
			if (i !== 0) s.hier1 = s.hier1 + '|';
			s.hier1 = s.hier1 + pageHierarchy[i];
			
			// s.pageName skips the second level and delimit by colon
			if (i !== 1) {
				if (i !== 0) s.pageName = s.pageName + ':';
				s.pageName = s.pageName + pageHierarchy[i];
			}
		}
		i++;
		break;

		// If no coding version, it must be coded at page level.
		default:
		break;
	}

	var s_code=s.t();if(s_code)document.write(s_code);
}

function tHubOmnitureVideoBeacon(videoId, videoLength, totalSeconds, startTimestamp, playSession) {
	var pev3 = [ videoId, videoLength, "T-Hub", totalSeconds, startTimestamp, playSession ];
	s.pev3 = pev3.join('--**--');
}

// Track links for My Shortcuts through an onClick to this function.
function tHubOmnitureLink(action, linkName) {
			s.manageVars("clearVars");
			s.tl(this, 'o', linkName + '-' + action);
}

// Look through all the links in the page and add an onClick event that
// reports link clicks to Omniture.
function reportLinks() {
	
	for (var i = 0; i < document.links.length; i++) {
		var a = document.links[i];
		if (a.href.search('r.aspx') !== -1) {
			a.onclick = function() {
				var queryString = {};
				this.href.replace(
					new RegExp("([^?=&]+)(=([^&]*))?", "g"),
					function($0, $1, $2, $3) { queryString[$1] = $3; }
				);

				var linkDescription = unescape(queryString['pn'] + ':' + queryString['mn'] + ':' + queryString['txt'] + ':' + queryString['url']);
				s.tl(this, "e", linkDescription);
			}

		}
	}
}

s.manageVars=new Function("c","l","f",""
+"var s=this,vl,la,vla;l=l?l:'';f=f?f:1 ;if(!s[c])return false;vl='pa"
+"geName,purchaseID,channel,server,pageType,campaign,state,zip,events"
+",products,transactionID';for(var n=1;n<51;n++){vl+=',prop'+n+',eVar"
+"'+n+',hier'+n;}if(l&&(f==1||f==2)){if(f==1){vl=l;}if(f==2){la=s.spl"
+"it(l,',');vla=s.split(vl,',');vl='';for(x in la){for(y in vla){if(l"
+"a[x]==vla[y]){vla[y]='';}}}for(y in vla){vl+=vla[y]?','+vla[y]:'';}"
+"}s.pt(vl,',',c,0);return true;}else if(l==''&&f==1){s.pt(vl,',',c,0"
+");return true;}else{return false;}");
s.clearVars=new Function("t","var s=this;s[t]='';");
s.lowercaseVars=new Function("t",""
+"var s=this;if(s[t]){s[t]=s[t].toString();s[t]=s[t].toLowerCase();}");
