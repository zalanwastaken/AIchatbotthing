--! LOVE 11.5 LUA 5.1
local socket = require("socket")
local ip, port = "127.0.0.1", 5005 --? change to server ip
local tcp = assert(socket.tcp())
tcp:settimeout(5)
local function split(input, delimiter)
    local result = {}
    for match in (input..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end
local function getaimsg(msg)
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
local function getaudio()
    tcp:connect(ip, port)
    tcp:send("audio")
    local ret = ""
    while true do
        local s, status, partial = tcp:receive(4096)
        if status == "closed" then
            tcp:close()
            break
        else
            if (s or partial) ~= nil then
                ret = ret..(s or partial)
            else
                tcp:close()
                break
            end
        end
    end
    return(love.data.newByteData(ret))
end
function love.load()
    ar = {"\b"}
    local fnt = love.graphics.newFont(16)
    love.graphics.setFont(fnt)
    x = love.mouse.getX()
    y = love.mouse.getY()
    love.keyboard.setKeyRepeat(true)
end
function love.update(dt)
    x = love.mouse.getX()
    y = love.mouse.getY()
end
function love.draw()
    local eye_radius = 40
    local pupil_radius = 20
    local left_eye_x = love.graphics.getWidth()/4
    local left_eye_y = love.graphics.getHeight()/4
    local right_eye_x = love.graphics.getWidth()/4 + (love.graphics.getWidth()/2)
    local right_eye_y = love.graphics.getHeight()/4
    local mouse_x, mouse_y = love.mouse.getX(), love.mouse.getY()
    local left_dir_x = mouse_x - left_eye_x
    local left_dir_y = mouse_y - left_eye_y
    local left_dir_len = math.sqrt(left_dir_x^2 + left_dir_y^2)
    left_dir_x, left_dir_y = left_dir_x / left_dir_len, left_dir_y / left_dir_len
    local right_dir_x = mouse_x - right_eye_x
    local right_dir_y = mouse_y - right_eye_y
    local right_dir_len = math.sqrt(right_dir_x^2 + right_dir_y^2)
    right_dir_x, right_dir_y = right_dir_x / right_dir_len, right_dir_y / right_dir_len
    local left_pupil_x = left_eye_x + left_dir_x * (eye_radius - pupil_radius)
    local left_pupil_y = left_eye_y + left_dir_y * (eye_radius - pupil_radius)
    local right_pupil_x = right_eye_x + right_dir_x * (eye_radius - pupil_radius)
    local right_pupil_y = right_eye_y + right_dir_y * (eye_radius - pupil_radius)
    love.graphics.setColor(0.5, 0.5, 1)
    love.graphics.circle("fill", left_eye_x, left_eye_y, eye_radius)
    love.graphics.circle("fill", right_eye_x, right_eye_y, eye_radius)
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", left_pupil_x, left_pupil_y, pupil_radius)
    love.graphics.circle("fill", right_pupil_x, right_pupil_y, pupil_radius)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(ar, 0, love.graphics.getHeight()/2-math.abs(16), love.graphics.getWidth(), "center")
    if resp == nil then
        love.graphics.arc("fill", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 + 100, 100, 0, math.pi)
        love.graphics.setColor(0, 0, 0)
        love.graphics.arc("fill", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 + 100, 50, 0, math.pi)
        love.graphics.setColor(1, 1, 1)
    else
        love.graphics.printf(resp, 0, love.graphics.getHeight()/2, love.graphics.getWidth(), "center")
    end
    love.graphics.setColor(1, 0, 0, 1)
    if resp == nil then
        love.graphics.print("DEBUG\nDPI:"..love.graphics.getDPIScale().."\nRESP:".."no".."\nIP and PORT:"..ip..":"..port.."\nInput array: "..#ar)
    else
        love.graphics.print("DEBUG\nDPI:"..love.graphics.getDPIScale().."\nRESP:".."yes".."\nIP and PORT:"..ip..":"..port.."\nInput array: "..#ar)
    end
    love.graphics.setColor(1, 1, 1, 1)
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
        if tmp == "/kill" then
            tcp:connect(ip, port)
            tcp:send(tmp)
            tcp:close()
            love.event.quit(0)
            return
        end
        resp = getaimsg(tmp)
        print(resp)
        if not(love.filesystem.getInfo("audio")) then
            love.filesystem.createDirectory("audio")
        end
        local audiofile = love.filesystem.newFile("audio/tts.wav", "w")
        audiofile:write(getaudio())
        audiofile:close()
        audiofile = nil
        local audio = love.audio.newSource("audio/tts.wav", "static")
        love.audio.play(audio)
    end
    if key == "backspace" and #ar ~= 0 then
        ar[#ar] = nil
        ar[#ar] = nil
        ar[#ar+1] = "\b"
    end
end
--[[
* Made by Zalan(Zalander) aka zalanwastaken with LÖVE and some 🎔
! ________  ________  ___       ________  ________   ___       __   ________  ________  _________  ________  ___  __    _______   ________      
!|\_____  \|\   __  \|\  \     |\   __  \|\   ___  \|\  \     |\  \|\   __  \|\   ____\|\___   ___\\   __  \|\  \|\  \ |\  ___ \ |\   ___  \    
! \|___/  /\ \  \|\  \ \  \    \ \  \|\  \ \  \\ \  \ \  \    \ \  \ \  \|\  \ \  \___|\|___ \  \_\ \  \|\  \ \  \/  /|\ \   __/|\ \  \\ \  \   
!     /  / /\ \   __  \ \  \    \ \   __  \ \  \\ \  \ \  \  __\ \  \ \   __  \ \_____  \   \ \  \ \ \   __  \ \   ___  \ \  \_|/_\ \  \\ \  \  
!    /  /_/__\ \  \ \  \ \  \____\ \  \ \  \ \  \\ \  \ \  \|\__\_\  \ \  \ \  \|____|\  \   \ \  \ \ \  \ \  \ \  \\ \  \ \  \_|\ \ \  \\ \  \ 
!   |\________\ \__\ \__\ \_______\ \__\ \__\ \__\\ \__\ \____________\ \__\ \__\____\_\  \   \ \__\ \ \__\ \__\ \__\\ \__\ \_______\ \__\\ \__\
!    \|_______|\|__|\|__|\|_______|\|__|\|__|\|__| \|__|\|____________|\|__|\|__|\_________\   \|__|  \|__|\|__|\|__| \|__|\|_______|\|__| \|__|
!                                                                                \|_________|                                                   
--]]
