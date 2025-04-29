//---------------- DATALICIOUS -----------------------------
adserverHTML = '';
var BPstartsign=new RegExp("SignUp:Online:New or Existing");
	if (BPstartsign.test(s.pageName)) {
		s.events=s.apl(s.events,'event50',',',1);
		adserverHTML += '<iframe src="//view.atdmt.com/jaction/oattrm_broadband_funnelstart/v3/" width="1" height="1"></iframe>';
	}

var BPfinishsign=new RegExp("SignUp:Online:ConfirmationThankYou");
	if (BPfinishsign.test(s.pageName)) {
		s.events=s.apl(s.events,'event51',',',1);
		adserverHTML += '<iframe src="//view.atdmt.com/jaction/oattrm_broadband_purchase/v3/" width="1" height="1"></iframe>';
		adserverHTML += '<img height="1" width="1" style="border-style:none;" alt="" src="http://www.googleadservices.com/pagead/conversion/1066482506/?label=OC7OCMrfggIQyvbE_AM&amp;guid=ON&amp;script=0"/>';
	} 

// Create a DIV to contain the code
var datAdserver = document.createElement('div');
datAdserver.id = 'datAdserverDIV';
datAdserver.style.visibility="hidden";
datAdserver.style.width="1";
datAdserver.style.height="1";

// Add the code to the DIV
datAdserver.innerHTML=adserverHTML;

// Append the DIV to the body
document.body.appendChild(datAdserver);
//---------------- DATALICIOUS -----------------------------
