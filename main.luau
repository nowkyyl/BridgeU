assert(WebSocket, "Your executor not have websocket")

local currentWsClient = getgenv().currentWsClient
if currentWsClient then
	currentWsClient:Close()
end

local wsClient = WebSocket.connect("ws://localhost:8080/")
getgenv().currentWsClient = wsClient

local HttpService = game:GetService("HttpService")
local fileName = "Unknown"
local function HandleError(errMsg)
	local time = os.date("!*t")
	local formatted = string.format("[%02d:%02d:%02d] %s", time.hour, time.min, time.sec, errMsg)
	wsClient:Send("Output:" .. HttpService:JSONEncode({ fileName = fileName, error = formatted }))
end

local envsByFile = {}
local threadsByFile = {}
wsClient.OnMessage:Connect(function(message)
	if message:sub(1, 7) == "Output:" then return end

	local ok, payload = pcall(HttpService.JSONDecode, HttpService, message)
	if not ok then return HandleError("\27[31mInvalid payload received\27[0m") end

	if type(payload) ~= "table" or not payload.content then return HandleError("\27[31mMissing script content\27[0m") end

	local currentFileName = payload.fileName or "Unknown"
	fileName = currentFileName

	local func, err = loadstring(payload.content)
	if not func then return HandleError("\27[31m" .. err .. "\27[0m") end

	if envsByFile[currentFileName] then
		local fileThread = threadsByFile[currentFileName]
		coroutine.close(fileThread)

		threadsByFile[currentFileName] = nil
		envsByFile[currentFileName] = nil
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
		script = script,
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
			local msg = table.concat({...}, " ")
			HandleError(msg)
		end,
		warn = function(...)
			local msg = table.concat({...}, " ")
			HandleError("\27[33m" .. msg .. "\27[0m")
		end,
		error = function(...)
			local msg = table.concat({...}, " ")
			HandleError("\27[31m" .. msg .. "\27[0m")
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
	envsByFile[currentFileName] = env

	local thread = coroutine.create(func)
	threadsByFile[currentFileName] = thread
	
	local success, execErr = coroutine.resume(thread)
	if not success then
		HandleError("\27[31m" .. execErr .. "\27[0m")
	end
end)


wsClient.OnClose:Connect(function()
	getgenv().currentWsClient = nil
end)
