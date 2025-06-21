function init()
  m.top.observeField("focusPercent", "onFocusChange")
end function

function onContentChange()
  m.top.findNode("keyLabel").text = m.top.itemContent.title
end function

function onFocusChange()
  bg = m.top.findNode("background")
  if m.top.focusPercent = 1 then
    ' It's focused
    bg.color = "#F0F0F0FF"
  else
    ' It's not focused
    bg.color = "#444444FF"
  end if
end function
