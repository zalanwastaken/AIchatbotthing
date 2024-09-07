local utils = {
    warn = function(msg)
        if msg ~= nil then
            print("[WARN]["..os.time().."] "..msg)
        else
            print("[WARN]["..os.time().."] NO MESSAGE PROVIDED !")
        end
    end
}
local tcpfuncs = {
    POST = function(sock, ip, port, data) --! Dont rely on this to post critical message this will NOT provide a error message if the message fails to post
        sock:connect(ip, port)
        sock:send(data)
        sock:close()
    end,
    FETCH = function(sock, ip, port, data, buff)
        local ret = ""
        if buff == nil then
            buff = 4096
        end
        sock:connect(ip, port)
        sock:send(data)
        while true do
            local s, status, partial = sock:receive(buff)
            if status:lower() == "socket is not connected" then
                sock:close()
                ret = nil
                utils.warn("Unable to connect to sever at "..ip..":"..tostring(port).." using buff "..buff)
                break
            end
            if status:lower() == "closed" then
                ret = ret..(s or partial)
                sock:close()
                break
            else
                if (s or partial) ~= nil then
                    ret = ret..(s or partial)
                else
                    sock:close()
                    break
                end
            end
        end
        return(ret)
    end,
    PING = function(sock, ip, port, data, buff)
        if buff == nil then
            buff = 1024
        end
        sock:connect(ip, port)
        sock:send(data)
        local s, status, partial = sock:receive(buff)
        if status:lower() == "timeout" or status:lower() == "socket is not connected" then
            sock:close()
            utils.warn("Unable to ping server at "..ip..":"..tostring(port).." using buff: "..buff)
            return(nil)
        else
            sock:close()
            return(s or partial)
        end
    end
}
return(tcpfuncs)
