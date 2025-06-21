function init()
    m.top.setFocus(true) 
    m.isPolling = false
    m.background = m.top.findNode("background")
    m.timer1_group = m.top.findNode("timer1_group")
    m.timer1_logo = m.top.findNode("timer1_logo")
    m.timer1_text = m.top.findNode("timer1_text")
    m.timer1_text.font.size = 80
    m.timer2_group = m.top.findNode("timer2_group")
    m.timer2_logo = m.top.findNode("timer2_logo")
    m.timer2_text = m.top.findNode("timer2_text")
    m.timer2_text.font.size = 80
    m.pollTimer = m.top.findNode("pollTimer")
    
    port = createObject("roMessagePort")
    m.top.observeField("close", port)
    
    checkAndSetInitialIP()
end function

Sub mainEventLoop()
    while(true)
        msg = wait(0, m.port)
        if type(msg) = "roSGNodeEvent" and msg.isField("close") and msg.getData() = true then
            ' The scene's 'close' field was set to true, so we exit this subroutine,
            ' which ends the event loop for this scene.
            return
        end if
    end while
End Sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press and key = "options" then
        if m.isPolling then
            m.pollTimer.control = "stop"
            m.isPolling = false
        end if
        m.top.close = true
        return true
    end if
    return false
end function

function checkAndSetInitialIP()
    reg = CreateObject("roRegistrySection", "TCGTimerApp")
    serverIP = reg.read("serverIP")
    if serverIP = invalid or serverIP = "" then
        settings = m.top.createChild("SettingsScene")
        settings.observeField("ipAddress", "onSettingsFinished")
        settings.setFocus(true)
    else
        m.top.serverIP = serverIP
        startPolling()
    end if
end function

function onSettingsFinished(event as object)
    m.top.setFocus(true)
    dialog = event.getRoSGNode()
    if dialog <> invalid then dialog.unobserveField("ipAddress")
    checkAndSetInitialIP()
end function

function startPolling()
    if m.isPolling = false then
        m.isPolling = true
        m.pollTimer.observeField("fire", "onPollServer")
        m.pollTimer.control = "start"
        onPollServer()
    end if
end function

function onPollServer()
    if m.top.serverIP <> invalid and m.top.serverIP <> "" then
        task = createObject("roSGNode", "NetworkTask")
        task.observeField("output", "onNetworkResult")
        task.url = "http://" + m.top.serverIP + "/api/timer_status"
        task.control = "run"
    end if
end function

function onNetworkResult(event as object)
    data = event.getData()
    if data <> invalid then
        updateUI(data)
    else
        print "Network task failed to return valid data."
    end if
end function

function updateUI(data as object)
    if data <> invalid and data.theme <> invalid and data.timers <> invalid then
        m.background.color = data.theme.background + "FF"
        defaultFontColor = data.theme.font_color + "FF"
        lowTimeSeconds = 5 * 60
        if data.theme.low_time_minutes <> invalid then
            lowTimeSeconds = data.theme.low_time_minutes * 60
        end if
        warningEnabled = data.theme.warning_enabled <> false
        
        updateSingleTimer("1", data.timers["1"], defaultFontColor, lowTimeSeconds, warningEnabled)
        updateSingleTimer("2", data.timers["2"], defaultFontColor, lowTimeSeconds, warningEnabled)
        adjustLayout()
    end if
end function

function updateSingleTimer(id as string, timerData as object, fontColor as string, lowTime as integer, warningOn as boolean)
    group = m.top.findNode("timer" + id + "_group")
    logo = m.top.findNode("timer" + id + "_logo")
    label = m.top.findNode("timer" + id + "_text")

    if timerData <> invalid and timerData.enabled then
        group.visible = true
        totalSeconds = timerData.time_remaining_seconds
        hours = int(totalSeconds / 3600)
        minutes = int((totalSeconds mod 3600) / 60)
        secs = totalSeconds mod 60
        
        timeStr = ""
        if hours = 0 then
            timeStr = Right("0" + minutes.toStr(), 2) + "m" + Right("0" + secs.toStr(), 2) + "s"
        else
            timeStr = Right("0" + hours.toStr(), 2) + "h" + Right("0" + minutes.toStr(), 2) + "m" + Right("0" + secs.toStr(), 2) + "s"
        end if
        
        if timerData.times_up then label.text = "TIMES UP" else label.text = timeStr
        
        if warningOn and timerData.is_running and totalSeconds > 0 and totalSeconds < lowTime then
            label.color = "#FF0000FF"
        else
            label.color = fontColor
        end if
        
        logoBaseUrl = "http://" + m.top.serverIP + "/static/uploads/"
        if timerData.logo_filename <> invalid and timerData.logo_filename <> "" then
            logo.uri = logoBaseUrl + timerData.logo_filename
        else
            logo.uri = ""
        end if
    else
        group.visible = false
    end if
end function

function adjustLayout()
    is1Visible = m.timer1_group.visible
    is2Visible = m.timer2_group.visible
    
    yPos = "175" ' Vertically center the content block

    if is1Visible and is2Visible then
        m.timer1_group.translation = "[220, " + yPos + "]"
        m.timer2_group.translation = "[660, " + yPos + "]"
    else if is1Visible then
        m.timer1_group.translation = "[440, " + yPos + "]"
    else if is2Visible then
        m.timer2_group.translation = "[440, " + yPos + "]"
    end if
end function
