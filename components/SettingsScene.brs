function init()
    m.ipDisplay = m.top.findNode("ipDisplay")
    m.keypad = m.top.findNode("keypadGrid")
    m.ipString = ""
    
    keypadContent = createObject("roSGNode", "ContentNode")
    keys = [ "1", "2", "3", "Del", "4", "5", "6", ".", "7", "8", "9", ":", "0", "SAVE" ]
    
    for each key in keys
        buttonNode = keypadContent.createChild("ContentNode")
        buttonNode.title = key
    end for
    
    m.keypad.content = keypadContent
    m.keypad.setFocus(true)
    m.keypad.observeField("itemSelected", "onKeypadButtonSelected")
end function

function onKeypadButtonSelected()
    selectedIndex = m.keypad.itemSelected
    buttonData = m.keypad.content.getChild(selectedIndex)
    key = buttonData.title

    if key = "SAVE" then
        if m.ipString <> "" then
            ' Set our output field. main.brs is watching this.
            m.top.ipAddress = m.ipString
        end if
    else if key = "Del" then
        if m.ipString.Len() > 0 then
            m.ipString = m.ipString.Left(m.ipString.Len() - 1)
        end if
    else
        m.ipString = m.ipString + key
    end if

    m.ipDisplay.text = "IP:PORT - " + m.ipString
end function