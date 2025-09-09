assert(WebSocket, "Your executor not have websocket")

local HttpService = game:GetService("HttpService")
local function HandleError(wsClient, fileName, type, err)
	wsClient:Send("output" .. HttpService:JSONEncode({
		fileName = fileName,
		type = type,
		error = err,
	}))
end

local threadsByFile = getgenv().threadsByFile or {}
local player = game:GetService("Players").LocalPlayer
while true do
	local ok, wsClient = pcall(WebSocket.connect, `ws://localhost:8080/?userId={player.UserId}`)
	if not ok then
		print("Reconnecting...")
		task.wait(5)
		continue
	end

	wsClient.OnMessage:Connect(function(content)
		if content:sub(1, 6) == "output" then
			return
		end

		local fileNameLength = string.unpack(">I4", content)
		local fileName = string.sub(content, 5, 4 + fileNameLength)
		content = string.sub(content, 5 + fileNameLength)

		local func, err = loadstring(content)
		if not func then
			HandleError(wsClient, fileName, "ERROR", err)
			return error(err)
		end

		local fileThread = threadsByFile[fileName]
		if fileThread then
			coroutine.close(fileThread)
		end

 		setfenv(func, setmetatable({
			print = function(...)
				local args = { ... }
				for i = 1, #args do
					args[i] = tostring(args[i])
				end
				local msg = table.concat(args, " ")
				print(msg)
				HandleError(wsClient, fileName, "INFO", msg)
			end,
		
			warn = function(...)
				local args = { ... }
				for i = 1, #args do
					args[i] = tostring(args[i])
				end
				local msg = table.concat(args, " ")
				warn(msg)
				HandleError(wsClient, fileName, "WARN", msg)
			end,
		
			error = function(...)
				local args = { ... }
				for i = 1, #args do
					args[i] = tostring(args[i])
				end
				local msg = table.concat(args, " ")
				HandleError(wsClient, fileName, "ERROR", msg)
				error(msg)
			end
		}, { __index = getfenv(f) }))

		local thread = coroutine.create(func)
		threadsByFile[fileName] = thread
		getgenv().threadsByFile = threadsByFile

		local ok, exec = coroutine.resume(thread)
		if not ok then
			HandleError(wsClient, fileName, "ERROR", exec)
			error(exec)
		end
	end)

	wsClient.OnClose:Wait()
end
