local socket = require("socket")
local ip, port = "127.0.0.1", 5005 -- change to server ip
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
function love.load()
    ar = {"\b"}
    local fnt = love.graphics.newFont(16)
    love.graphics.setFont(fnt)
    x = love.mouse.getX()
    y = love.mouse.getY()
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
    love.graphics.printf(resp or "N/A", 0, love.graphics.getHeight()/2, love.graphics.getWidth(), "center")
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
