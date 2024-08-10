local socket = require("socket")
local ip, port = "127.0.0.1", 5005
local tcp = assert(socket.tcp())
tcp:settimeout(5)
function getaimsg(msg)
    tcp:connect(ip, port)
    tcp:send(msg)
    while true do
        local s, status, partial = tcp:receive(4096)
        if status == "closed" then
            tcp:close()
            return(s or partial)
        end
    end
end
function love.load()
    ar = {"\b"}
    local fnt = love.graphics.newFont(20)
    love.graphics.setFont(fnt)
end
function love.update(dt)
end
function love.draw()
    love.graphics.print(ar)
    love.graphics.print(resp or "N/A", 0, 20)
end
function love.textinput(key)
    ar[#ar] = nil
    ar[#ar+1] = key
    ar[#ar+1] = "\b"
end
function love.keypressed(key)
    if key == "return" then
        local tmp = ""
        for i = 1, #ar-1, 1 do
            tmp = tmp..ar[i]
        end
        resp = getaimsg(tmp)
        print(resp)
    end
    if key == "backspace" then
        ar[#ar] = nil
        ar[#ar] = nil
        ar[#ar+1] = "\b"
    end
end
