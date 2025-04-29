// Global variable to hold our stuff
var TM_SC = TM_SC || {};
TM_SC.recordPageView = function(hierarchy){

	// Define the report suites. Use development until approved to go live.
	
	// Define first levels of hierarchy
	if (window.location.hostname.indexOf('.skynews.com.au') !== -1) {
		TM_SC.reportsuites = 'telstrabpbigpondprd';
	} else {
		TM_SC.reportsuites = 'telstrabpbigponddev';
	}
	s.un = TM_SC.reportsuites;

	s.hier1 = '';
	s.pageName = '';
	TM_SC.hierarchy = hierarchy.split('|');
	var i;
	for (i = 0; i < TM_SC.hierarchy.length; i += 1) {
		
		switch (i) {
			case 0:
				s.prop1 = TM_SC.hierarchy[i];
				s.eVar1 = TM_SC.hierarchy[i];
				break;
			case 1:
				s.prop2 = TM_SC.hierarchy[i];
				s.eVar2 = TM_SC.hierarchy[i];
				break;
			case 2:
				s.prop3 = TM_SC.hierarchy[i];
				s.eVar3 = TM_SC.hierarchy[i];
				break;
			case 3:
				s.channel = TM_SC.hierarchy[i];
				s.eVar4 = TM_SC.hierarchy[i];
				break;
			case 4:
				s.prop4 = TM_SC.hierarchy[i];
				s.eVar5 = TM_SC.hierarchy[i];
				break;
			case 5:
				s.prop5 = TM_SC.hierarchy[i];
				s.eVar15 = TM_SC.hierarchy[i];
				break;
		}
		
		// Build up the hierarchy delimited by pipes
		if (i !== 0) {
			s.hier1 += '|';
		}
		s.hier1 += TM_SC.hierarchy[i];
		
		// s.pageName skips the second level and delimit by colon
		if (i !== 1) {
			if (i !== 0) {
				s.pageName = s.pageName + ':';
			}
			s.pageName = s.pageName + TM_SC.hierarchy[i];
			
		}
		
	}
	var s_code = s.t();
	if (s_code) {
		document.write(s_code);
	}
	s.manageVars('clearVars');
};

s.manageVars=new Function("c","l","f",""
+"var s=this,vl,la,vla;l=l?l:'';f=f?f:1 ;if(!s[c])return false;vl='pa"
+"geName,purchaseID,channel,server,pageType,campaign,state,zip,events"
+",products,transactionID';for(var n=1;n<76;n++){vl+=',prop'+n+',eVar"
+"'+n+',hier'+n;}if(l&&(f==1||f==2)){if(f==1){vl=l;}if(f==2){la=s.spl"
+"it(l,',');vla=s.split(vl,',');vl='';for(x in la){for(y in vla){if(l"
+"a[x]==vla[y]){vla[y]='';}}}for(y in vla){vl+=vla[y]?','+vla[y]:'';}"
+"}s.pt(vl,',',c,0);return true;}else if(l==''&&f==1){s.pt(vl,',',c,0"
+");return true;}else{return false;}");
s.clearVars=new Function("t","var s=this;s[t]='';"); s.lowercaseVars=new Function("t",""
+"var s=this;if(s[t]&&t!='events'){s[t]=s[t].toString();if(s[t].index"
+"Of('D=')!=0){s[t]=s[t].toLowerCase();}}");
s.split=new Function("l","d",""
+"var i,x=0,a=new Array;while(l){i=l.indexOf(d);i=i>-1?i:l.length;a[x"
+"++]=l.substring(0,i);l=l.substring(i+d.length);}return a");