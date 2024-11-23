local execName = getexecutorname and getexecutorname() or ""
local function HandleError(ws, err)
    local msg = `[{execName}] {err}`
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
                    HandleError(ws, res)
                end
            else
                HandleError(ws, err)
            end
        end)

        ws.OnClose:Wait()
    end
    task.wait(1)
end
