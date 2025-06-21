function init()
  m.top.functionName = "main"
end function

function main()
    url = m.top.url
    result = invalid

    if url <> invalid and url <> "" then
        urlTransfer = CreateObject("roUrlTransfer")
        urlTransfer.SetUrl(url)
        port = CreateObject("roMessagePort")
        urlTransfer.SetMessagePort(port)
        if urlTransfer.AsyncGetToString() then
            msg = wait(5000, port)
            if type(msg) = "roUrlEvent" then
                code = msg.GetResponseCode()
                if code = 200 then
                    jsonString = msg.GetString()
                    if jsonString <> invalid and jsonString <> "" then
                        parsedJson = ParseJson(jsonString)
                        if parsedJson <> invalid then
                            result = parsedJson
                        end if
                    end if
                end if
            end if
        end if
    end if
    
    m.top.output = result
end function