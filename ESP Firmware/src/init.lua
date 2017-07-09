--- hackAIR ESP Firmware
-- Handles WiFi setup and network communications
-- @version 0.4.0
-- @author Thanasis Georgiou

--- The server URL used for sending data to the hackAIR project
server_URL = "http://hackair.draxis.gr:8000/sensors/arduino/measurements"
auth_token = ""

function sent_data(args)
    -- Prepare HTTP headers
    local headers = 'Content-Type: application/json\r\n' ..
                    'HTTP Accept header: application/vnd.hackair.v1+json\r\n' ..
                    'Authorization: ' .. auth_token .. '\r\n'

    -- Parse arguments from serial and encode them in JSON
    local pm25, pm10, battery, tamper, err =
        string.match(args, "([^,]+),([^,]+),([^,]+),([^,]+),([^,]*)")

    local body = string.format([[{
        "reading": {
            "PM2.5_AirPollutantValue":"%s",
            "PM10_AirPollutantValue":"%s"
        },
        "battery":"%s",
        "tamper":"%s",
        "error":"%s"
    }]], pm25, pm10, battery, tamper, err)

    -- Make the request
    --noinspection UnusedDef
    http.post(server_URL, headers, body,
        function(code, data)
            uart.write(0, tostring(code))
        end
    )
end

--- Handle UART commands
-- The first word (string until first space) is the command, the rest is
-- parameters. Each command is terminated with a \n.
-- @param UART input, must be parsed
function handle_uart(data)
    -- Parse parameters
    local com, args = string.match(data, "([^%s]+)%s([^%s]+)")
    if com == nil then
        com = string.sub(data, 1, -2)
    end

    -- Execute commands
    if com == 'e+raw' then -- Enter raw mode (lua console)
        uart.on("data")
        uart.setup(0, 115200, 8, uart.PARITY_NONE, uart.STOPBITS_1, 1)
        print('Lua Shell mode')
    elseif com == 'e+restart' then -- Restart ESP
        node.restart()
    elseif com == 'e+version' then -- Version info
        uart.write(0, 'v4')
    elseif com == 'e+send' then -- Send data to server
        if args == nil then
            print('Command e+send requires parameters (pm25, pm10, battery, tamper, error)')
        else
            sent_data(args)
        end
    elseif com == 'e+clearap' then -- Clear saved access points
        wifi.sta.clearconfig()
        node.restart()
    elseif com == 'e+token' then -- Grab the token for authorization
        if args == nil then
            print('Command e+token required parameters (token)')
        else
            auth_token = args
        end
    elseif com == 'e+wifi' then -- Set the SSID to connect to
        if args == nil then
            print('Command e+wifi requires two parameters, SSID and password')
            print('SSIDs and passwords with commas "," are not supported, please use the WiFi method')
        else
            local ssid, password = string.match(args, "([^,]+),([^,]*)")
            if ssid ~= nil and password ~= nil then
                wifi.sta.config({ssid = ssid, pwd = password, auto = true})
                enduser_setup.stop()
            else
                print('Invalid parameters')
            end
        end
    elseif com == 'e+isready' then -- Is the ESP ready and connected?
        if wifi.sta.getip() ~= nil then
            uart.write(0, tostring(1))
        else
            uart.write(0, tostring(0))
        end
    else
        print('Unknown command ' .. com)
    end
end

-- Start listening to UART for commands
uart.setup(0, 115200, 8, uart.PARITY_NONE, uart.STOPBITS_1, 0)
uart.on('data', "\n", handle_uart, 0)

ssid, password, bssid_set, bssid = wifi.sta.getconfig()
if ssid == '' then
    print('No WiFi configuration stored, going into AP mode')
    enduser_setup.start(
      function()
          -- Print debug info
          ssid, password, bssid_set, bssid = wifi.sta.getconfig()
          print('Connected to '.. ssid .. ' with password ' .. password .. ' as: ' .. wifi.sta.getip())
      end,
      function(err, str)
          print('enduser_setup: Err #' .. err .. ': ' .. str)
      end
    )
else
    wifi.setmode(wifi.STATION)
    wifi.sta.connect()
end

-- Display a warning message to the prompt
print('hackAir ESP Firmware')
print('Entering serial command mode, to use the Lua terminal send "e+raw"')
