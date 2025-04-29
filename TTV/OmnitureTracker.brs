'**********************************************************
'**  Omniture Helper
'**
'** @author:    Jon-Anthoney de Boer; Kamal Singh
'** @email:     Jon.deBoer@team.telstra.com; kamal.singh@team.telstra.com
'**
'** Utility class to provide Omniture tracking capability to the Roku. This is a port of the T-Box Omniture 
'** tracking library that was implemented in JavaScript. There are alterations where it made sense.
'**
'** Copyright (c) 2015 Telstra
'**********************************************************


' Instantiate Omniture Tracker
Function OmnitureTracker()
    if m.OmnitureTracker = invalid then
        m.OmnitureTracker = CreateOmnitureTracker()
        
        ' Copy Interfaces properties
        if m.OmnitureTracker <> invalid and m.top.omniture <> invalid
            for each key in m.top.omniture.Keys()
                if key <> invalid and m.top.omniture.Lookup(key) <> invalid
                    m.OmnitureTracker.AddReplace(key, m.top.omniture.Lookup(key))
                end if
            end for
            
            ' Check for Experiments
            if m.global <> invalid and m.global.experiments <> invalid and m.global.experiments <> ""
                m.OmnitureTracker.AddReplace("experiments", m.global.experiments)
            end if
            
            ' Check for UUID
            if m.global <> invalid and m.global.UserUUID <> invalid
                m.OmnitureTracker.uuid = m.global.UserUUID
            else
                m.OmnitureTracker.uuid = "unknown"
            end if
            
            m.top.omniture = m.OmnitureTracker
        end if
    end if

    return m.OmnitureTracker
End Function


' Track a general UI/UX screen view in the app 
' 
' @param heirarchy a pipe-delimited set of string values identifying the logical location or user interaction 
' in the app for the event being tracked.
' @return boolean true | false whether the tracking request was successful.
Function OmnitureTracker_trackScreen(heirarchy as String, options = invalid as Object) as Boolean
    ' fail fast if we don't have required data
    SendLog("OMNITURE", "==================== Omniture ====================")
    if heirarchy = invalid then 
        SendLog("ERROR", "trackEvent() - failed due to missing mandatory input 'heirarchy'.")
        return false
    end if
    
    SendLog("OMNITURE", "Omniture track screen: " + heirarchy )
    
    heirarchyBase = ""
    if m.configs <> invalid
        heirarchyBase = m.configs.OmnitureHeirarchyBase
    end if
    
    if heirarchyBase = invalid then 
        SendLog("ERROR", "trackScreen() - failed due to missing Omniture configuration data 'OmnitureHeirarchyBase'.")
        return false
    end if 
    
    ' Align some screens to Omniture SD requirements
    if heirarchy = "CustomMyLibrary" then
        return true ' the specific item time (movies, tv shows) will be used on load instead ...
    end if
    
    ' For hierarchy tracks, we don't seem to require consumption item context info (at least based on the Presto on T-Box example)
    if m.ClearData() then
        m.c.Clear() ' remove elements, so parsing in send() functions as expected
        if m.c.Count() > 0 then
            SendLog("ERROR", "trackScreen() - failed to clean context variable, tracker data will be invalid.")
            return false
        else 
            ' process our UX heirarchy
            heirarchy = heirarchyBase + heirarchy
            m.heirarchy = heirarchy.Tokenize("|")
            
            if m.heirarchy.count() < 1 then
                SendLog("ERROR", "trackScreen() - failed due to invalid composed initial heirarchy - [" + m.heirarchy + "]")
                return false
            end if  
            
            ' ID to pass for v74 is more flexible, but vid and v24 need to be serial (Kamal/Steve email 201707221344)
            uuid = m.uuid
            if uuid = invalid OR uuid = "" then
                uuid = "unknown"
            end if
            m.s.v74 = uuid
            m.s.v24 = m.s.vid
            m.s.vid = CreateObject("roDeviceInfo").GetDeviceUniqueId()
            
            ' TTV-143
            ' gets the major, minor and build versions
            appInfo = CreateObject("roAppInfo")
            m.s.c10 = appInfo.GetValue("major_version") + "." + appInfo.GetValue("minor_version") + " ("+ appInfo.GetValue("build_version") + ")"
            
            ' Build up components of the tracking beacon
            for i=0 to m.heirarchy.count()-1
                element = m.heirarchy[i]
                if element = invalid then
                    SendLog("WARN", "trackScreen() - Invalid heirarchy element at position ["+tostr(i)+"]")
                    element = ""
                end if
                
                ' Build up tracking vars for the heirarchy elements
                if i = 0 then
                    m.s.c1 = element
                    m.s.v1 = element
                else if i = 1 then
                    m.s.c2 = element
                    m.s.v2 = element
                else if i = 2 then
                    m.s.c3 = element
                    m.s.v3 = element
                else if i = 3 then
                    m.s.ch = element
                    m.s.v4 = element
                else if i = 4 then
                    m.s.c4 = element
                    m.s.v5 = element
                else if i = 5 then
                    m.s.c5 = element
                    m.s.v15 = element
                end if
                
                if m.s.h1 = invalid then
                    m.s.h1 = ""
                end if
                
                ' Build up the hierarchy delimited by pipes
                if i <> 0 AND element <> invalid then
                    m.s.h1 = m.s.h1 + "|"
                end if
                m.s.h1 = m.s.h1 + element
                
                if m.s.pageName = invalid then
                    m.s.pageName = ""
                end if
                
                if i <> 0 then
                    m.s.pageName = m.s.pageName + ":"
                end if
                m.s.pageName = m.s.pageName + element
                    
            end for
            ' Extra options input param as requested by Kamal S via email 201507201227. See the attachment, lines 72-102
            if type(options) = "roAssociativeArray" then
                if (type(options.prodEvent) = "String" OR type(options.prodEvent) = "roString") AND (type(options.products) = "String" OR type(options.products) = "roString") then
                    options.products = options.products.Replace("$","")
                    options.products = options.products.Replace(";","")
                    options.products = options.products.Replace(",","")
                    
                    price = ""
                    if type(options.price) = "String" OR type(options.price) = "roString" then
                        price = options.price.Replace("$","")
                    end if
                    
                    purchaseId = ""
                    if type(options.purchaseID) = "String" OR type(options.purchaseID) = "roString" then
                        purchaseId = options.purchaseID
                    end if
                    
                    ' Additional checking as per https://bigpond.jira.com/browse/TTV-681
                    ' This adds some more handling for additional Prod Events.
                    if options.prodEvent = "offerView" then ' i.e. Bad Mums:123:24 month:foxtel 
                        m.s.events = "event20"
                        m.s.products = ";" + options.products 
                    else if options.prodEvent = "offerCheck" then ' Checked out offer details
                        m.s.events = "event23"
                        m.s.products = ";" + options.products 
                    else if options.prodEvent = "offerTaken" then ' User has taken up offer note price is set to $0.0
                        m.s.events = "event19"
                        m.s.products = ";" + options.products + ";1;0.00" 
                        m.s.purchaseID = purchaseId
                    else if options.prodEvent = "offerHide" then ' User has hidden offer
                        m.s.events = "event21"
                        m.s.products = ";" + options.products 
                    else if options.prodEvent = "offerHideNo" then ' User has not hidden offer
                        m.s.events = "event22"
                        m.s.products = ";" + options.products 
                    else if options.prodEvent = "prodView" then                      ' i.e. EST:SD:OC:MovieA         
                        m.s.events = "prodView"
                        m.s.products = ";" + options.products                   
                    else if options.prodEvent = "checkout" then                 ' OK Rent button
                        m.s.events = "scCheckout"
                        m.s.products = ";" + options.products + ";1;" + price   
                    else if options.prodEvent = "pin" then                      ' User enters rating PIN 
                        m.s.events = "scAdd"
                        m.s.products = ";" + options.products + ";1;" + price                                
                    else if options.prodEvent = "purchase" then                 ' Rental: Revenue only
                        m.s.events = "purchase"
                        m.s.products = ";" + options.products + ";1;" + price   
                        m.s.purchaseID = purchaseId                        
                    else if options.prodEvent = "buyout" then                   ' EST : OK Buy button
                        m.s.events = "event13"
                        m.s.products = ";" + options.products + ";1;" + price   
                    else if options.prodEvent = "HDRES" then                    ' User Selects HD Title
                        m.s.events = "event14"
                        m.s.products = ";" + options.products + ";1;" + price   
                    else if options.prodEvent = "ESTpurchase" then              ' EST: Revenue only
                        m.s.events = "event15,event16"
                        m.s.products = ";" + options.products + ";1;" + price + ";event15=1|event16=" + price 
                        m.s.purchaseID = purchaseId
                    else if options.prodEvent = "purchaseHD" then               ' Rental: HD Revenue only
                        m.s.events = "event14,purchase"
                        m.s.products = ";" + options.products + ";1;" + price
                        m.s.purchaseID = purchaseId
                    else if options.prodEvent = "ESTpurchaseHD" then            ' EST: HD Revenue only
                        m.s.events = "event14,event15,event16"
                        m.s.products = ";" + options.products + ";1;" + price + ";event14=1|event15=1|event16=" + price
                        m.s.purchaseID = purchaseId
                    end if
                end if  ' prodEvent 
                
                ' Other Options without prodEvents    
                if type(options.search) = "String" OR type(options.search) = "roString" then
                    searchKey = options.search.Replace("|", "")                 ' remove any pipe from users entry string
                    m.s.v22 = searchKey
                end if

                'TTV2
                if type(options.ListTitle) = "String" OR type(options.ListTitle) = "roString" then
                    m.s.v12 = options.ListTitle     
                end if                              
                if type(options.ShowTitle) = "String" OR type(options.ShowTitle) = "roString" then
                    m.s.v39 = options.ShowTitle 
                end if                                      
                if type(options.Classification) = "String" OR type(options.Classification) = "roString" then
                    m.s.v40 = options.Classification                                    
                end if  
                if type(options.Genre) = "String" OR type(options.Genre) = "roString" then
                    m.s.v17 = options.Genre                                     
                end if  
                if type(options.Rating) = "String" OR type(options.Rating) = "roString" then
                    m.s.v16 = options.Rating                                    
                end if  
                if type(options.Season) = "String" OR type(options.Season) = "roString" then
                    m.s.v41 = options.Season                                    
                end if  
                if type(options.ContentType) = "String" OR type(options.ContentType) = "roString" then
                    m.s.v44 = options.ContentType                                   
                end if  
                if type(options.ProgressBar) = "String" OR type(options.ProgressBar) = "roString" then
                    m.s.v43 = options.ProgressBar                                   
                end if  
                if type(options.Year) = "String" OR type(options.Year) = "roString" then
                    m.s.v42 = options.Year                                  
                end if  
                if type(options.Channel) = "String" OR type(options.Channel) = "roString" then
                    m.s.v9 = options.Channel                                    
                end if  
                if type(options.Position) = "String" OR type(options.Position) = "roString" then
                    m.s.v55 = options.Position                                  
                end if
                if type(options.CarouselPosition) = "String" OR type(options.CarouselPosition) = "roString" then
                    m.s.v58 = options.CarouselPosition                                  
                end if
                if type(options.SearchResults) = "String" OR type(options.SearchResults) = "roString" then
                    m.s.v59 = options.SearchResults                                  
                end if
                if type(options.CategoryID) = "String" OR type(options.CategoryID) = "roString" then
                    m.s.v69 = options.CategoryID                                  
                end if
                if type(options.Category) = "String" OR type(options.Category) = "roString" then
                    m.s.v17 = options.Category                                     
                end if    
                	              
                ' add in partner name
                if type(options.PartnerName) = "String" OR type(options.PartnerName) = "roString" then
                    m.s.v52 = options.PartnerName 
                end if
                                
                ' live tv pause
                if type(options.Tunein) = "String" OR type(options.Tunein) = "roString" AND options.Tunein = "3" AND (type(options.Channel) = "String" OR type(options.Channel) = "roString") AND (type(options.ShowTitle) = "String" OR type(options.ShowTitle) = "roString") then
                    m.s.events = "event35=1"
                    m.s.v9 = options.Channel
                    m.s.v10 = options.ShowTitle
				end if
					
				' live tv unpause								
                if type(options.Tunein) = "String" OR type(options.Tunein) = "roString" AND  options.Tunein = "4" AND (type(options.Channel) = "String" OR type(options.Channel) = "roString") AND (type(options.duration) = "String" OR type(options.duration) = "roString") AND (type(options.ShowTitle) = "String" OR type(options.ShowTitle) = "roString") then
                    m.s.events = "event34=1,event36="+options.duration
                    m.s.v9 = options.Channel
                    m.s.v10 = options.ShowTitle
				end if
				
                'live pause buffer full & live tv forced unpause
                if type(options.Tunein) = "String" OR type(options.Tunein) = "roString" AND options.Tunein = "5" AND (type(options.Channel) = "String" OR type(options.Channel) = "roString") AND (type(options.duration) = "String" OR type(options.duration) = "roString") AND (type(options.ShowTitle) = "String" OR type(options.ShowTitle) = "roString") then
                    m.s.events = "event37=1,event34=1,event36="+options.duration
                    m.s.v9 = options.Channel
                    m.s.v10 = options.ShowTitle
				end if 	
				
				'Instant replay 
                if type(options.Tunein) = "String" OR type(options.Tunein) = "roString" AND options.Tunein = "6" AND (type(options.Channel) = "String" OR type(options.Channel) = "roString") AND (type(options.ShowTitle) = "String" OR type(options.ShowTitle) = "roString") then
                    m.s.events = "event38=1"
                    m.s.v9 = options.Channel
                    m.s.v10 = options.ShowTitle
				end if
				
                'tunein
                if type(options.Tunein) = "String" OR type(options.Tunein) = "roString" AND options.Tunein = "1" AND (type(options.Channel) = "String" OR type(options.Channel) = "roString") AND (type(options.ShowTitle) = "String" OR type(options.ShowTitle) = "roString") then
                    m.s.events = "event40=1"
                    m.s.v9 = options.Channel
                    m.s.v10 = options.ShowTitle
                end if  
                
                'tuneout                                
                if type(options.Tunein) = "String" OR type(options.Tunein) = "roString" AND  options.Tunein = "0" AND (type(options.Channel) = "String" OR type(options.Channel) = "roString") AND (type(options.duration) = "String" OR type(options.duration) = "roString") AND (type(options.ShowTitle) = "String" OR type(options.ShowTitle) = "roString") then
                    m.s.events = "event41=1,event42="+options.duration
                    m.s.v9 = options.Channel
                    m.s.v10 = options.ShowTitle
                end if
                
                'keep alive *every 20mins
                if type(options.Tunein) = "String" OR type(options.Tunein) = "roString" AND  options.Tunein = "2" AND (type(options.Channel) = "String" OR type(options.Channel) = "roString") AND (type(options.duration) = "String" OR type(options.duration) = "roString") AND (type(options.ShowTitle) = "String" OR type(options.ShowTitle) = "roString") then
                    m.s.events = "event42=" + options.duration
                    m.s.v9 = options.Channel
                    m.s.v10 = options.ShowTitle
                end if
                if type(options.search) = "String" OR type(options.search) = "roString" then
                    m.s.v22 = options.search 
                end if                                          
                if type(options.SetReminder) = "String" OR type(options.SetReminder) = "roString" then
                    m.s.v56 = options.SetReminder                                   
                end if                 
                if type(options.option) = "String" OR type(options.option) = "roString" then
                    m.s.v65 = "Options Clicked" 
                end if          
                
                'TTV2 end
                if type(options.assetId) = "String" OR type(options.assetId) = "roString" then
                    m.s.v35 = options.assetId                                   
                end if  
                if type(options.UserType) = "String" OR type(options.UserType) = "roString" then
                    m.s.v37 = options.UserType 
                end if                              
                if type(options.Modal) = "String" OR type(options.Modal) = "roString" then
                    m.s.v45 = options.Modal 
                end if                              
               if type(options.telstraID) = "String" OR type(options.telstraID) = "roString" then
                    m.s.v70 = options.telstraID                                     
                end if  
                if type(options.bundleID) = "String" OR type(options.bundleID) = "roString" then
                    m.s.v38 = options.bundleID 
                end if                              
                if type(options.setupDate) = "String" OR type(options.setupDate) = "roString" then
                    m.s.v19 = options.setupDate
                    m.s.events = "event1"
                end if                              
                if type(options.rentalDate) = "String" OR type(options.rentalDate) = "roString" then
                    m.s.v20 = options.rentalDate 
                end if                              
                if type(options.promo) = "String" OR type(options.promo) = "roString" then
                    m.s.v48 = options.promo 
                end if                    
                
                ' Add hasTrailer option
                if type(options.hasTrailer) = "String" OR type(options.hasTrailer) = "roString" and options.hasTrailer = "1" then
                    m.s.events = m.s.events + ",event24=1"
                end if  
            end if
            ' end options input param support
            return m.Send() 
        end if
    else 
        SendLog("DEBUG", "trackScreen() - unable to clear old tracker object data.")
        return false
    end if  
End Function


' Track an event, passing to the relevant tracking function
Function OmnitureTracker_trackEvent(eventName = "" as String, info = invalid as Dynamic) as Boolean
    returnVal = false
    if eventName <> invalid then        
        SendLog("OMNITURE", "==================== Omniture ====================")
        if eventName <> "VideoPlayPositionChanged" then
            SendLog("OMNITURE", "*** Omniture track event [" + eventName + "]")
        end if
        
        vidTitle = "unknown"
        vidUrl = "unknown"
        vidDuration = 0
        
        if OmnitureTracker().mediaTitle <> invalid then
            vidTitle = OmnitureTracker().mediaTitle
        end if
        
        if OmnitureTracker().mediaAssetId <> invalid then
            vidAssetId = OmnitureTracker().mediaAssetId
        end if
        
        if OmnitureTracker().mediaDuration <> invalid then 
            vidDuration = OmnitureTracker().mediaDuration
        end if
            
        if OmnitureTracker().mediaStream <> invalid
            vidUrl = OmnitureTracker().mediaStream
        end if
        
        if eventName = "VideoPlayStarted" then
            ' TODO: Pass on Options 
            'options = { RES: "<SD or HD>", OC: "<0 or 1>, assetId:"<movieID>" }
            options = invalid ' TODO: Add in Options 
            OmnitureTracker().OnMediaOpen(vidTitle, vidDuration, vidUrl, options) 
            OmnitureTracker().playing = true
            returnVal = true
        else if eventName = "VideoPlayInterrupted" then
            OmnitureTracker().OnMediaUpdate(true) ' interrupted by pressing 'back' button to leave VSV
            OmnitureTracker().ResetPlayState()
            returnVal = true
        else if eventName = "VideoPlayResumed" then
            if type(info) = "roAssociativeArray" and info.hier <> invalid
                OmnitureTracker().TrackScreen(info.hier + "|Resume|" + vidTitle)
                returnVal = true
            else
                OmnitureTracker().TrackScreen("|Resume|" + vidTitle)
                returnVal = true
            end if
        else if eventName = "VideoPlayPaused" then
            if type(info) = "roAssociativeArray" and info.hier <> invalid
                OmnitureTracker().TrackScreen(info.hier + "|Pause|" + vidTitle)
                returnVal = true
            else
                OmnitureTracker().TrackScreen("|Pause|" + vidTitle)
                returnVal = true
            end if
        else if eventName = "VideoPlayStop" then
            OmnitureTracker().OnMediaClose()
            OmnitureTracker().ResetPlayState()
            returnVal = true
        else if eventName = "VideoPlayComplete" then
            OmnitureTracker().OnMediaComplete()
            OmnitureTracker().ResetPlayState()
            returnVal = true
        end if
    end if
    
    return returnVal
End Function


' Tracking method for when the user initiated a media open event to consume some content
'
' @param videoId the identifier of the video, likely to be the embed code (ooyala) or external ID.
' @param duration the length of the identified content in seconds.
' @param videoUrl the source URL of the identified content.
' @return boolean true | false whether the tracking request was successful.
Function OmnitureTracker_onMediaOpen(videoId as String, duration as Integer, videoUrl as String, options = invalid as Object) as Boolean
    m.playing = true 
    m.lastUpdateTime = 0
    assetId = ""
    
    ' fail fast for inputs and required data
    if videoId = invalid then 
        SendLog("ERROR", "onMediaOpen() - failed due to missing mandatory input 'videoId'.")
        return false
    else if duration = invalid then
        SendLog("ERROR", "onMediaOpen() - failed due to missing mandatory input 'duration'.")
        return false
    else if videoUrl = invalid then
        SendLog("ERROR", "onMediaOpen() - failed due to missing mandatory input 'videoUrl'.")
        return false
    end if 
    
	if type(options) = "roAssociativeArray" then
        OC = "" ' yes or no 
        if type(options.OC) = "String" OR type(options.OC) = "roString" then
            OC = options.OC
            if OC = "1" then
                videoId = "OC:" + videoId
            end if
        end if

        RES = "" 'SD or HD 
        if type(options.RES) = "String" OR type(options.RES) = "roString" then
            RES = options.RES
            if RES = "SD" then
                videoId = "SD:" + videoId
            else if RES = "HD" then
                videoId = "HD:" + videoId
            end if
        end if
        
        if type(options.assetId) = "String" OR type(options.assetId) = "roString" then
            assetId = options.assetId 'stick to evar35
        end if
        
        ' Unable to determine if video was an EST  
        'EST = "" ' yes or no
        'if type(options.EST) = "String" OR type(options.EST) = "roString" then
        '   EST = options.EST
        '    if EST = "1" then
        '       options.products = "EST:" + options.products 
        '    end if
        'end if
     end if
    
    ' Set assetId from Omniture if it wasn't passed through from options
    if assetId = "" and type(m.mediaAssetId) = "String" OR type(m.mediaAssetId) = "roString" then
        assetId = m.mediaAssetId
    end if
    
    ' fail fast for any globals required for this tracking call
    channel = m.configs.OmnitureChannelName
    if channel = invalid then 
        SendLog("ERROR", "onMediaOpen() - failed due to missing global 'OmnitureChannelName'.")
        return false
    end if
    
    playerName = m.configs.OmniturePlayerName
    if playerName = invalid then
        SendLog("ERROR", "onMediaOpen() - failed due to missing global 'OmniturePlayerName'.")
        return false
    end if 
    
    ' init our tracker ready for this call
    if m.ClearData() then
        m.s.c = ""
        m.s.pe = "m_s"
        m.s.pev3 = "video"
        
        m.c = CreateObject("roAssociativeArray")
        m.c.a = ""
        m.c.contentType = "video"
        m.c.media = ""
        m.c.channel = channel
        m.c.name = videoId
        m.c.playerName = playerName
        m.c.length = duration.ToStr()
        m.c.view = "true"
        m.c.videoURL = videoUrl
        m.c.assetId = assetId
         
        return m.Send()
    else 
        SendLog("DEBUG", "onMediaOpen() - unable to clear old tracker object data.")
    end if
    
    return false
End Function


' Tracking method to report on a piece of content's playback progress.
'
' @param timePlayed an integer value representing the progress made through playback of the content.
' @return boolean true | false whether the tracking request was successful.
Function OmnitureTracker_onMediaUpdate(userInitiated = false as Boolean) as Boolean

    if m.playing = true then
        
        ' fail fast for and globals required for this call
        channel = m.configs.OmnitureChannelName
        if channel = invalid then 
            SendLog("ERROR", "onMediaUpdate() - failed due to missing global 'OmnitureChannelName'.")
            return false
        end if
        
        playerName = m.configs.OmniturePlayerName
        if playerName = invalid then
            SendLog("ERROR", "onMediaUpdate() - failed due to missing global 'OmniturePlayerName'.")
            return false
        end if 
        
        updateInterval = m.configs.OmniturePlaybackUpdateInterval
        if updateInterval = invalid then
            SendLog("ERROR", "onMediaOpen() - failed due to missing global 'OmniturePlaybackUpdateInterval'.")
            return false
        end if 
        
        ' compute time since last update call
        m.date.Mark()
        now = m.date.AsSeconds()
        delta = 0
        if m.lastUpdateTime > 0 then
            delta = now - m.lastUpdateTime
        else
            m.lastUpdateTime = now
        end if
        
        ' guard against weird delta that could skew play time metrics. It is possible if something goes awry and the OmnitureTracker's lastUpdateTime is reset ...
        if (userInitiated = true OR (delta >= updateInterval.ToInt() AND delta < 21600)) then
            userInit = "false"
            if userInitiated = true then
                userInit = "true"
            end if
            
            ' init our tracker ready for this call
            if m.ClearData() then
                m.s.c = ""
                m.s.pe = "m_i"
                m.s.pev3 = "video"
                
                m.c = CreateObject("roAssociativeArray")
                m.c.a = ""
                m.c.contentType = "video"
                m.c.media = ""
                m.c.channel = channel
                m.c.playerName = playerName
                m.c.timePlayed = delta.ToStr()
                m.c.segmentView = "true"
                
                m.lastUpdateTime = now
                return m.Send()
            else 
                SendLog("DEBUG", "onMediaUpdate() - unable to clear old tracker object data.")
            end if
        end if
    end if
    
    return false
End Function


' Tracking method for when the content was played through to natural completion.
'
' @return boolean true | false whether the tracking request was successful.
Function OmnitureTracker_onMediaComplete() as Boolean    
    ' fail fast for and globals required for this call
    channel = m.configs.OmnitureChannelName
    if channel = invalid then 
        SendLog("ERROR", "onMediaUpdate() - failed due to missing global 'OmnitureChannelName'.")
        return false
    end if
    
    playerName = m.configs.OmniturePlayerName
    if playerName = invalid then
        SendLog("ERROR", "onMediaUpdate() - failed due to missing global 'OmniturePlayerName'.")
        return false
    end if 
    
    ' init our tracker ready for this call
    if m.ClearData() then
        m.s.c = ""
        m.s.pe = "m_i"
        m.s.pev3 = "video"
        
        m.c = CreateObject("roAssociativeArray")
        m.c.a = ""
        m.c.contentType = "video"
        m.c.media = ""
        m.c.channel = channel
        m.c.playerName = playerName
        m.c.segmentView = "true"
        m.c.complete = "true"
        
        m.Send()
        CreateOmnitureTracker()
    else 
        SendLog("DEBUG", "onMediaComplete() - unable to clear old tracker object data.")
        return false
    end if
End Function


' Tracking method for when the user initiated a media close event prior to natural playback completion.
'
' @param timePlayed an integer value representing the progress made through playback of the content prior 
' to the user ending playback.
' @return boolean true | false whether the tracking request was successful.
Function OmnitureTracker_onMediaClose() as Boolean
    ' fail fast for and globals required for this call
    channel = m.configs.OmnitureChannelName
    if channel = invalid then 
        SendLog("ERROR", "onMediaUpdate() - failed due to missing global 'OmnitureChannelName'.")
        return false
    end if
    
    playerName = m.configs.OmniturePlayerName
    if playerName = invalid then
        SendLog("ERROR", "onMediaUpdate() - failed due to missing global 'OmniturePlayerName'.")
        return false
    end if 
    
    ' compute time since last update call
    m.date.Mark()
    now = m.date.AsSeconds()
    delta = now - m.lastUpdateTime
    m.lastUpdateTime = now
    
    ' init our tracker ready for this call
    ' guard against weird delta that could skew play time metrics. It is possible if something goes awry and the OmnitureTracker's lastUpdateTime is reset ...
    if m.ClearData() AND delta < 21600 then
        SendLog("OMNITURE", "onMediaClose() delta ["+delta.ToStr()+"]")
        m.s.c = ""
        m.s.pe = "m_i"
        m.s.pev3 = "video"
        
        m.c = CreateObject("roAssociativeArray")
        m.c.a = ""
        m.c.contentType = "video"
        m.c.media = ""
        m.c.channel = channel
        m.c.playerName = playerName
        m.c.timePlayed = delta.ToStr()
        m.c.segmentView = "true"
        
        m.lastUpdateTime = now
        return m.Send()
    else 
        SendLog("DEBUG", "onMediaClose() - unable to clear old tracker object data.")
        return false
    end if
End Function


' Utility function that is called by the tracking functions above to build a HTTP GET request based on a passed model
' object & some configuration elements. Then, make the HTTP GET request.
'
' @return boolean true | false whether the tracking request was successful.
Function OmnitureTracker_send() as Boolean
    ' ID to pass for v74 is more flexible, but vid and v24 need to be serial (Kamal/Steve email 201707221344)
    uuid = m.uuid
    if uuid = invalid OR uuid = "" then
        uuid = "unknown"
    end if
    m.s.v74 = uuid
    m.s.v24 = m.s.vid
    m.s.vid = CreateObject("roDeviceInfo").GetDeviceUniqueId()
    
    ' Experiments
    if (type(m.experiments) = "String" OR type(m.experiments) = "roString") and m.experiments <> "" then
        m.s.v36 = m.experiments                  ' stick to evar36
    end if
    ' Firmware Version
    di = CreateObject("roDeviceInfo")
    m.s.v23 = di.GetVersion()
    m.s.v64 = di.GetModel()
    m.s.v14 = di.GetConnectionType()
    m.s.v33 = di.GetVideoMode()
    m.s.v46 = di.GetExternalIp()
    m.s.v47 = di.GetTimeZone()
    m.s.v51 = di.TimeSinceLastKeypress()
    m.s.v27 = di.GetDeviceId() ' note deviceId can only be grabbed from RegApp run on the 4700TL
    
    ' Read values used in composition of the Omniture tracking URL
    visitorNamespace = m.configs.OmnitureVisitorNamespace
    reportSuites = m.configs.OmnitureReportSuites
    codingVersion = m.configs.OmnitureCodingVersion
    cookieDomainPeriods = m.configs.OmnitureCookieDomainPeriods
    trackingProtocol = m.configs.OmnitureTrackingProtocol
    if visitorNamespace = invalid OR reportSuites = invalid OR trackingProtocol = invalid OR codingVersion = invalid OR cookieDomainPeriods = invalid then
        SendLog("ERROR", "Omniture send() - failed due to missing Omniture configuration data.")
        return false
    end if
    
    ' Init the beacon URL
    if trackingProtocol = "https" then
        trackingServer = m.configs.OmnitureTrackingServerSsl
    else
        trackingServer = m.configs.OmnitureTrackingServer
    end if
    
    if trackingServer = invalid then
        SendLog("ERROR", "Omniture send() - failed due to invalid Omniture configuration for tracking server")
        return false
    end if
    m.imageUrl = trackingProtocol + "://" + trackingServer + "/b/ss/" + reportSuites + "/1/" + codingVersion + "/s" + GenerateRandomLargeNumber()
    m.imageUrl = m.imageUrl + "?AQB=1&ndh=1&ns=" + visitorNamespace + "&cdp=" + cookieDomainPeriods
    
    ' Go through contents of m.s object and add as URL-encoded name=attribute
    mediaElementFound = false
    aElementFound = false
    
    ' url encoding
    request = CreateObject("roUrlTransfer")
    for each property in m.s_keys
        if type(m.s[property]) <> invalid then
            if property = "c" and type(m.c) = "roAssociativeArray" and m.c.Count() > 0 then
                m.imageUrl = m.imageUrl + "&c."
                for each context in m.c_keys
                    if type(m.c[context]) <> invalid then                    
                        if context = "a" then 
                            m.imageUrl = m.imageUrl + "&a."
                            aElementFound = true
                        else if context = "media" then
                            m.imageUrl = m.imageUrl + "&media."
                            mediaElementFound = true
                        else 
                            propVal = m.c[context]                      
                            if propVal <> invalid AND type(propVal) <> "roAssociativeArray" then
                                m.imageUrl = m.imageUrl + "&" + context + "=" + request.Escape(propVal)
                            end if
                        end if
                    end if
                end for
                
                if mediaElementFound then
                    m.imageUrl = m.imageUrl + "&.media"
                end if
                
                if aElementFound then 
                    m.imageUrl = m.imageUrl + "&.a"
                end if
                
                m.imageUrl = m.imageUrl + "&.c"
            else 
                propVal = m.s[property]
                
                if propVal <> invalid AND type(propVal) <> "roAssociativeArray" then
                    m.imageUrl = m.imageUrl + "&" + property + "=" + request.Escape(propVal.ToStr())
                end if
            end if
        endif
    end for
        
    ' Boilerplate ending
    m.imageUrl = m.imageUrl + "&AQE=1"
    SendLog("OMNITURE", "Omniture: " + m.imageUrl )
    
    ' fire off the tracking beacon & set it up for checking in on the response later
    httpClient = CreateURLTransferObject(m.imageUrl, "GET")
    httpClient.AsyncGetToString()
    
    ' Determine whether to wait around for an API response
    if m.configs <> invalid and m.configs.AnalyticsWaitResponse <> invalid and type(m.configs.AnalyticsWaitResponse).InStr("Boolean") > -1 and m.configs.AnalyticsWaitResponse
        ' Wait for response
        event = wait(0, httpClient.GetMessagePort())  
        
        ' See similar comment in GoogleAnalytics.brs
        response = HandleResponse(event)
        
        ' Determine Response
        if response <> invalid and response.code >= 200 and response.code < 300
            ' No need to log success every time
            SendLog("OMNITURE", "Omniture send() :: success")
        else
            SendLog("OMNITURE", "Omniture send() :: failed")
        end if
    ' Otherwise, set and forget.
    else
        ' Wait for response
        event = wait(200, httpClient.GetMessagePort())  
    end if
    
    return true
End Function


' Provide the content item ready for tracking.
Function OmnitureTracker_setMediaDetails(contentItem = invalid as Object, rendition = "" As String, embedCode = "" As String)
    if contentItem.title <> invalid
        ' Set contentTitle
        contentTitle = contentItem.title
        
        ' Add rendition
        if rendition <> invalid and rendition <> "" and rendition <> " "
            contentTitle = contentTitle + " [" + rendition + "]"
        end if
        
        ' Add series and season if it is an episode
        if contentItem.assetType = "episode"
            contentTitle = contentItem.seriesName + " - " + contentItem.seasonName + " - " + contentTitle
        end if
        
        ' Set title
        SendLog("OMNITURE", "Omniture Media Title: " + contentTitle)
        m.mediaTitle = contentTitle
    end if
    
    if contentItem.assetId <> invalid
        SendLog("OMNITURE", "Omniture Media Asset ID: " + contentItem.assetId)
        m.mediaAssetId = contentItem.assetId
    end if
    
    if contentItem.duration <> invalid
        SendLog("OMNITURE", "Omniture Media Duration: " + contentItem.duration.ToStr())
        m.mediaDuration = contentItem.duration
    end if
    
    if embedCode <> invalid and embedCode <> ""
        SendLog("OMNITURE", "Omniture Embed Code: " + embedCode)
        m.mediaStream = embedCode
    end if
End Function


' Utility function that returns an object which will be used when configuring an Omniture tracking request. 
' The object will be parsed when building the actual HTTP GET request URL that ingests the tracking data 
' into Omniture's db. 
'
' @return a new Omniture tracking object
Function CreateOmnitureTracker() as Object
    ' init our base Omniture object
    obj = CreateObject("roAssociativeArray")
    
    ' Functions
    obj.ClearData       =   OmnitureTracker_clearData
    obj.TrackEvent      =   OmnitureTracker_trackEvent
    obj.TrackScreen     =   OmnitureTracker_trackScreen
    obj.OnMediaOpen     =   OmnitureTracker_onMediaOpen
    obj.OnMediaUpdate   =   OmnitureTracker_onMediaUpdate
    obj.OnMediaComplete =   OmnitureTracker_onMediaComplete
    obj.OnMediaClose    =   OmnitureTracker_onMediaClose
    obj.Send            =   OmnitureTracker_send
    obj.SetMedia        =   OmnitureTracker_setMediaDetails
    obj.ResetPlayState  =   OmnitureTracker_resetPlaybackState
        
    ' Properties
    obj.configs         =   GetSGGlobalConfigs()
    obj.imageUrl        =   invalid
    obj.heirarchy       =   []
    obj.uuid            =   ""
    obj.experiments     =   ""
    
    ' media details
    obj.mediaTitle      =   invalid
    obj.mediaAssetId    =   invalid
    obj.mediaDuration   =   invalid
    obj.mediaStream     =   invalid
    
    ' media context info
    obj.c               =   CreateContextDetailsObject()  
    obj.c_keys          =   CreateContextDetailsObjectKeys() 
    
    ' report details    
    obj.s               =   CreateReportDetailsObject()
    obj.s_keys          =   CreateReportDetailsObjectKeys()
    
    ' date for update tracking
    obj.date            =   CreateObject("roDateTime")
    obj.lastUpdateTime  =   0
    obj.playing         =   false
    
    return obj
End Function


' take an existing tracker object and wipe the properties
Function OmnitureTracker_clearData() as Boolean

    obj = OmnitureTracker()
    if obj <> invalid then
        obj.imageUrl        =   invalid
        obj.heirarchy       =   []
        obj.c               =   CreateContextDetailsObject()  
        obj.c_keys          =   CreateContextDetailsObjectKeys()     
        obj.s               =   CreateReportDetailsObject()
        obj.s_keys          =   CreateReportDetailsObjectKeys()
        obj.date            =   CreateObject("roDateTime")
        return true
    end if
    
    return false
End Function


' Utility function that returns an object which can be used to add context information to media tracking beacons.
'
' @return a new Omniture context details object
Function CreateContextDetailsObject() as Object
    obj = CreateObject("roAssociativeArray")
    
    obj.a             =   invalid
    obj.contentType   =   invalid
    obj.media         =   invalid
    obj.channel       =   invalid
    obj.name          =   invalid
    obj.playerName    =   invalid
    obj.length        =   invalid
    obj.timePlayed    =   invalid
    obj.view          =   invalid
    obj.segmentView   =   invalid
    obj.complete      =   invalid
    obj.videoURL      =   invalid
    obj.assetId       =   invalid
    
    return obj
End Function


' Utility function that returns an array of string literals that mirror the keys for the report context object
'
' @return a new key array for the Omniture report context object
Function CreateContextDetailsObjectKeys() as Object
    obj = []
    
    obj.Push("a")
    obj.Push("contentType")
    obj.Push("media")
    obj.Push("channel")
    obj.Push("name")
    obj.Push("playerName")
    obj.Push("length")
    obj.Push("timePlayed")
    obj.Push("view")
    obj.Push("segmentView")
    obj.Push("complete")
    obj.Push("videoURL")
    obj.Push("assetId")
    
    return obj
End Function


' Utility function that returns an object which can be used to add report details to tracking beacons.
'
' @return a new Omniture report details object
Function CreateReportDetailsObject() as Object
    obj = CreateObject("roAssociativeArray")
    
    obj.pageName  =   invalid
    obj.vid       =   invalid
    obj.ch        =   invalid
    obj.events    =   invalid
    obj.products  =   invalid
    obj.c1        =   invalid
    obj.v1        =   invalid
    obj.c2        =   invalid
    obj.v2        =   invalid
    obj.c3        =   invalid
    obj.v3        =   invalid
    obj.c4        =   invalid
    obj.v4        =   invalid
    obj.c5        =   invalid
    obj.v5        =   invalid
    obj.c10       =   invalid
    obj.h1        =   invalid
    obj.pe        =   invalid
    obj.pev2      =   invalid
    obj.pev3      =   invalid
    obj.c         =   invalid
    obj.v9        =   invalid
    obj.v10       =   invalid
    obj.v11       =   invalid
    obj.v12       =   invalid
    obj.v14       =   invalid
    obj.v15       =   invalid
    obj.v16       =   invalid
    obj.v17       =   invalid
    obj.v19       =   invalid
    obj.v20       =   invalid
    obj.v22       =   invalid
    obj.v23       =   invalid
    obj.v24       =   invalid
    obj.v27       =   invalid
    obj.v33       =   invalid
    obj.v35       =   invalid
    obj.v36       =   invalid
    obj.v37       =   invalid
    obj.v38       =   invalid
    obj.v39       =   invalid
    obj.v40       =   invalid
    obj.v41       =   invalid
    obj.v42       =   invalid
    obj.v43       =   invalid
    obj.v44       =   invalid
    obj.v45       =   invalid
    obj.v46       =   invalid
    obj.v47       =   invalid
    obj.v48       =   invalid
    obj.v51       =   invalid
    obj.v55       =   invalid
	obj.v56       =   invalid
	obj.v58       =   invalid
	obj.v59       =   invalid		
    obj.v64       =   invalid
    obj.v65       =   invalid
    obj.v69       =   invalid
    obj.v70       =   invalid
    obj.v74       =   invalid
    ' Mods for eCommerce tracking - via email from 201507201227KS
    obj.purchaseID  =   invalid
    
    return obj
End Function


' Utility function that returns an array of string literals that mirror the keys for the report details object
'
' @return a new key array for the Omniture report details object
Function CreateReportDetailsObjectKeys() as Object
    obj = []
    
    obj.Push("pageName")
    obj.Push("vid")
    obj.Push("ch")
    obj.Push("events")
    obj.Push("products")
    obj.Push("c")
    obj.Push("c1")
    obj.Push("v1")
    obj.Push("c2")
    obj.Push("v2")
    obj.Push("c3")
    obj.Push("v3")
    obj.Push("c4")
    obj.Push("v4")
    obj.Push("c5")
    obj.Push("v5")
    obj.Push("c10")
    obj.Push("v15")
    obj.Push("h1")
    obj.Push("pe")
    obj.Push("pev2")
    obj.Push("pev3")
    obj.Push("v9") 
    obj.Push("v10") 
    obj.Push("v11") 
    obj.Push("v12") 
    obj.Push("v14") 
    obj.Push("v15") 
    obj.Push("v16") 
    obj.Push("v17") 
    obj.Push("v19") 
    obj.Push("v20") 
    obj.Push("v22") 
    obj.Push("v23") 
    obj.Push("v24")
    obj.Push("v27")
    obj.Push("v33")
    obj.Push("v35")
    obj.Push("v36")
    obj.Push("v37")
    obj.Push("v38")
    obj.Push("v39")
    obj.Push("v40")
    obj.Push("v41")
    obj.Push("v42")
    obj.Push("v43")
    obj.Push("v44")
    obj.Push("v45")
    obj.Push("v46")
    obj.Push("v47")
    obj.Push("v48")
    obj.Push("v51")
    obj.Push("v52")
    obj.Push("v55")
    obj.Push("v56")
    obj.Push("v58")
    obj.Push("v59")
    obj.Push("v64")
    obj.Push("v65")
	obj.Push("v69")    	
    obj.Push("v70")
    obj.Push("v74")
    obj.Push("purchaseID")
    
    return obj
End Function


' Clean up from previous playback
Function OmnitureTracker_resetPlaybackState()
    if OmnitureTracker().playing = true then
        OmnitureTracker().playing = false
        OmnitureTracker().lastUpdateTime = 0
    end if
End Function


' Generate a large random number for use with the Omniture tracking URL path's 's' value
' eg: "1234560000000"
Function GenerateRandomLargeNumber() as String
    randomValue = Str(RND(0) * 10000000000000).Trim()
    return transformExpNumberStringToOrdinaryString(randomValue) 'Box(Str(RND(0)) * 10000000000000).Trim()
End Function


' Produce the String representation of a random, large number - without scientific notation or a leading space. 
' Thanks Roku developer forum!
' - http://forums.roku.com/viewtopic.php?p=431084&sid=b648d90a3f22b0f3052475c4134dc635
'
' @param inValue - String representation of a number in scientific notation. Eg: 1.23456e+13
' @return a regular number String. Eg: 1234560000000
Function transformExpNumberStringToOrdinaryString(inValue as String) as String
    inFloat = Val(inValue)
    output = inValue
    if output.InStr("e+") > -1 then
        exponent = 9
        divisor# = 10 ^ exponent
        high% = Int(inFloat / divisor#)
        low% = inFloat - (high% * divisor#)
        output = high%.ToStr() + PadLeft(low%.ToStr(), "0", exponent)
    end if
    return output 
End Function


' Helper for transformExpNumberStringToOrdinaryString() above
' Thanks Roku developer forum!
' - http://forums.roku.com/viewtopic.php?p=431084&sid=b648d90a3f22b0f3052475c4134dc635
function PadLeft(s, ch, toLen): 
    return String(toLen - len(s), ch) + s 
end function