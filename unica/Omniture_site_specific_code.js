// Global variable to hold our stuff
try {
	BP_SC;
}
catch(err) {
		BP_SC = {};
}
	

// Define the report suites. Use development until approved to go live.
BP_SC.reportsuites = 'telstraglobaldev,telstrabpbigponddev';
//BP_SC.reportsuites = 'telstraglobalprd,telstrabpdevelopercentreprd';

// ****************************************************
// * You shouldn't need to change anything below here *
// ****************************************************

// Method to strip any funny stuff out of the pageName
BP_SC.sanitisePageName = function(string){
	// replace | with hyphen.
	string = string.replace(/[|]/g, '-');
	return string;
};

BP_SC.reportingBeacon = function (codingVersion, hierarchy){

	// Report suites, if they exist
	if (BP_SC.reportsuites) {
		s.un = BP_SC.reportsuites;
	}
	
	// Split out pageHierarchy into the appropriate props and vars
	hierarchy = hierarchy.split('|');
	s.hier1 = '';
	s.pageName = '';
	var i;
	for (i = 0; i < hierarchy.length; i += 1) {
		switch (i) {
			case 0:
				s.prop1 = hierarchy[i];
				s.eVar1 = hierarchy[i];
				break;
			case 1:
				s.prop2 = hierarchy[i];
				s.eVar2 = hierarchy[i];
				break;
			case 2:
				s.prop3 = hierarchy[i];
				s.eVar3 = hierarchy[i];
				break;
			case 3:
				s.channel = hierarchy[i];
				s.eVar4 = hierarchy[i];
				break;
			case 4:
				s.prop4 = hierarchy[i];
				s.eVar5 = hierarchy[i];
				break;
			case 5:
				s.prop5 = hierarchy[i];
				s.eVar15 = hierarchy[i];
				break;
			default:
				s.prop5 += ':' + hierarchy[i];
				s.eVar15 += ':' + hierarchy[i];
		}
		
		// Build up the hierarchy delimited by pipes
		if (i !== 0) {
			s.hier1 = s.hier1 + '|'
		}
		s.hier1 = s.hier1 + hierarchy[i];
		
		// s.pageName skips the second level and delimit by colon
		if (i !== 1) {
			if (i !== 0) {
				s.pageName = s.pageName + ':';
			}
			s.pageName = s.pageName + hierarchy[i];
		}
	}
	
	var s_code = s.t();
	if (s_code) {
		document.write(s_code);
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
