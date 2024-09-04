local json = require("libs/json")
local tcpfuncs = require("libs/tcpfuncs")
local socket = require("socket")
local IP, PORT = "127.0.0.1", 5005
local tcp = assert(socket.tcp())
tcp:settimeout(5)
function love.load()
    local fnt = love.graphics.newFont(24)
    love.graphics.setFont(fnt)
    user = {"\b"}
    pass = {"\b"}
    sel = "user"
    local ping = tcpfuncs.PING(tcp, IP, PORT, json.encode({
        head = {
            type = "data/data",
            reqtype = "ping"
        },
        data = {
            ping = "ping"
        }
    }))
    if ping == nil then
        error("unable to connect to server")
    else
        ping = json.decode(ping)
        print(ping.head.type, ping.data.ping)
    end
end
function love.update()
end
function love.draw()
    love.graphics.printf("Login", 0, love.graphics.getHeight() / 2 - 75, love.graphics.getWidth(), "center")
    love.graphics.rectangle("line", love.graphics.getWidth() / 2 - 150, love.graphics.getHeight() / 2 - 125, 300, 250)
    love.graphics.rectangle("line", love.graphics.getWidth() / 2 - 100, love.graphics.getHeight() / 2 - 40, 200, 40)
    love.graphics.print(user or "", love.graphics.getWidth() / 2 - 100, love.graphics.getHeight() / 2 - 40)
    love.graphics.rectangle("line", love.graphics.getWidth() / 2 - 100, love.graphics.getHeight() / 2 + 10, 200, 40)
    love.graphics.print(pass or "", love.graphics.getWidth() / 2 - 100, love.graphics.getHeight() / 2 + 10)
    love.graphics.print("Login", love.graphics.getWidth() / 2 - 50, love.graphics.getHeight() / 2 + 70)
    love.graphics.rectangle("line", love.graphics.getWidth() / 2 - 50, love.graphics.getHeight() / 2 + 70, 100, 40)
end
function love.textinput(key)
    user[#user] = nil
    pass[#pass] = nil
    if sel == "user" then
        user[#user + 1] = key
    elseif sel == "pass" then
        pass[#pass + 1] = key
    end
    user[#user + 1] = "\b"
    pass[#pass + 1] = "\b"
end
function love.keypressed(key)
    user[#user] = nil
    pass[#pass] = nil
    if key == "return" then
        if sel == "user" then
            sel = "pass"
        elseif sel == "pass" then
            sel = "user"
        end
        print(sel)
    end
    if key == "backspace" then
        if sel == "user" then
            user[#user] = nil
        elseif sel == "pass" then
            pass[#pass] = nil
        end
    end
    user[#user + 1] = "\b"
    pass[#pass + 1] = "\b"
end
function love.mousepressed(x, y, button)
    if button == 1 then
        user[#user] = nil
        pass[#pass] = nil
        if x > love.graphics.getWidth() / 2 - 50 and x < love.graphics.getWidth() / 2 + 50 and y > love.graphics.getHeight() / 2 + 70 and y < love.graphics.getHeight() / 2 + 110 then
            local tmpuser = ""
            local tmppass = ""
            for i = 1, #user, 1 do
                tmpuser = tmpuser..user[i]
            end
            for i = 1, #pass, 1 do
                tmppass = tmppass..pass[i]
            end
            print(tmpuser, tmppass)
            tcpfuncs.FETCH(tcp, IP, PORT, json.encode({
                head = {
                    type = "data/data",
                    reqtype = "HELO"
                },
                data = {
                    user = tmpuser,
                    pass = tmppass
                }
            }))
        end
        user[#user + 1] = "\b"
        pass[#pass + 1] = "\b"
    end
end
