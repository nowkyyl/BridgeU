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
local player = game.Players.LocalPlayer
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
			return HandleError(wsClient, fileName, "ERROR", err)
		end

		local fileThread = threadsByFile[fileName]
		if fileThread then
			coroutine.close(fileThread)
		end

		local env = {
			-- core globals and functions
			assert = assert,
			getfenv = getfenv,
			setfenv = setfenv,
			collectgarbage = collectgarbage,
			getmetatable = getmetatable,
			setmetatable = setmetatable,
			loadstring = loadstring,
			newproxy = newproxy,
			next = next,
			pairs = pairs,
			ipairs = ipairs,
			pcall = pcall,
			xpcall = xpcall,
			rawequal = rawequal,
			rawget = rawget,
			rawset = rawset,
			rawlen = rawlen,
			select = select,
			tonumber = tonumber,
			tostring = tostring,
			type = type,
			typeof = typeof,
			settings = settings,
			unpack = unpack or table.unpack,
			_VERSION = _VERSION,

			-- standard libraries
			math = math,
			string = string,
			table = table,
			coroutine = coroutine,
			utf8 = utf8,
			os = os,
			debug = debug,
			bit32 = bit32,
			buffer = buffer,

			-- globals and core objects
			game = game,
			workspace = workspace,
			--script = script,
			shared = shared,
			_G = _G,
			Instance = Instance,
			Enum = Enum,

			-- utility
			wait = wait,
			task = task,
			spawn = spawn,
			Spawn = Spawn,
			delay = delay,
			require = require,

			-- overrides
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
				warn(msg)
			end,

			-- internal modules and services
			SecurityCapabilities = SecurityCapabilities,
			SharedTable = SharedTable,
			Secret = Secret,
			Stats = Stats,
			stats = stats,
			Content = Content,
			CatalogSearchParams = CatalogSearchParams,
			DateTime = DateTime,
			DockWidgetPluginGuiInfo = DockWidgetPluginGuiInfo,
			Delay = Delay,
			ElapsedTime = ElapsedTime,
			elapsedTime = elapsedTime,
			Font = Font,
			File = File,
			Faces = Faces,
			FloatCurveKey = FloatCurveKey,
			gcinfo = gcinfo,
			Game = Game,
			OverlapParams = OverlapParams,
			PathWaypoint = PathWaypoint,
			Path2DControlPoint = Path2DControlPoint,
			PhysicalProperties = PhysicalProperties,
			printidentity = printidentity,
			Random = Random,
			Ray = Ray,
			RaycastParams = RaycastParams,
			Region3 = Region3,
			Region3int16 = Region3int16,
			RotationCurveKey = RotationCurveKey,
			tick = tick,
			time = time,
			TweenInfo = TweenInfo,
			UDim = UDim,
			UserSettings = UserSettings,
			vector = vector,
			Vector2 = Vector2,
			Vector3 = Vector3,
			Vector2int16 = Vector2int16,
			Vector3int16 = Vector3int16,
			Version = Version,
			version = version,
			Wait = Wait,
			Workspace = Workspace,
			ypcall = ypcall,

			-- types and data structures
			Axes = Axes,
			BrickColor = BrickColor,
			CFrame = CFrame,
			Color3 = Color3,
			ColorSequence = ColorSequence,
			ColorSequenceKeypoint = ColorSequenceKeypoint,
			NumberRange = NumberRange,
			NumberSequence = NumberSequence,
			NumberSequenceKeypoint = NumberSequenceKeypoint,
			Rect = Rect,
			UDim2 = UDim2,
		}

		for i, v in getgenv() do
			env[i] = v
		end
		setfenv(func, env)

		local thread = coroutine.create(func)
		threadsByFile[fileName] = thread
		getgenv().threadsByFile = threadsByFile

		local ok, exec = coroutine.resume(thread)
		if not ok then
			HandleError(wsClient, fileName, "ERROR", exec)
		end
	end)

	wsClient.OnClose:Wait()
end
