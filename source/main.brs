Sub Main()
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)
    
    ' This outer loop allows us to relaunch the settings screen
    while(true)
        reg = CreateObject("roRegistrySection", "TCGTimerApp")
        serverIP = reg.read("serverIP")

        scene = invalid
        if serverIP = invalid or serverIP = "" then
            ' If no IP is saved, show the settings screen
            scene = screen.CreateScene("SettingsScene")
            screen.show()
            ' Watch the 'ipAddress' field on the settings scene
            scene.observeField("ipAddress", m.port)
        else
            ' IP is saved, show the main timer viewer
            scene = screen.CreateScene("MainScene")
            scene.serverIP = serverIP
            screen.show()
            ' Watch the 'close' field on the main scene (for the * button)
            scene.observeField("close", m.port)
        end if

        ' This inner loop waits for a signal from the active scene
        while(true)
            msg = wait(0, m.port)
            msgType = type(msg)

            if msgType = "roSGNodeEvent" then
                ' Check which field sent the signal
                if msg.getField() = "ipAddress" then
                    ' SettingsScene is telling us it has a new IP
                    ipAddress = msg.getData()
                    if ipAddress.Instr(":") = 0 then
                        ipAddress = ipAddress + ":80"
                    end if
                    ' Save it to the registry
                    reg.write("serverIP", ipAddress)
                    reg.Flush()
                    exit while ' Exit inner loop to relaunch
                
                else if msg.getField() = "close" then
                    ' MainScene is telling us to go back to settings
                    exit while ' Exit inner loop to relaunch
                
                else if msg.isScreenClosed() then
                    ' The whole app is closing
                    return
                end if
            end if
        end while
        
        scene.close = true
    end while
End Sub
