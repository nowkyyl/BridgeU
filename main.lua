local execName = getexecutorname()
local function HandleError(ws, err)
    local time = os.date("!*t")
    local msg = `[{execName} | {("%02d:%02d:%02d"):format(time.hour, time.min, time.sec)}] {err}`
    ws:Send("OutPut - " .. msg)
    error(msg, 2)
end

while true do
    local succ, ws = pcall(WebSocket.connect, 'ws://localhost:33882/')
    if succ then
        ws.OnMessage:Connect(function(code)
            if code:sub(1, 8) == "OutPut - " then return end

            local func, err = loadstring(code)
            if func then
                local suc, res = pcall(func)
                if not suc then
                    pcall(HandleError, ws, res)
                end
            else
                pcall(HandleError, ws, res)
            end
        end)

        ws.OnClose:Wait()
    end
    task.wait(1)
end
