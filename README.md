# BridgeU

BridgeU is a Visual Studio Code extension that sends script content to WebSocket clients, allowing you to broadcast your current file or watch files for changes and send updates automatically.

## Features

- **Run Script from Editor**  
  Send the current active file content to connected WebSocket clients with a single command.

- **Right-Click to Send**  
  Right-click any file in the Explorer and select **BridgeU: RunScript** or **BridgeU: Watcher** to send or watch that file.

- **File Watcher**  
  Automatically watch a selected file for changes and broadcast updates in real-time.

- **Automatic Watcher on Startup**  
  Configure the extension to watch a specific file when VSCode starts by setting the path in your workspace settings.

- **Output Channel**  
  See connection logs, broadcast status, and errors in a dedicated output channel named **BridgeU** inside VSCode.

## Usage

### Run Script

- Open the file you want to send.
- Use the command palette (`Ctrl+Shift+P` or `Cmd+Shift+P`) and run **BridgeU: RunScript**.
- Alternatively, right-click the file in Explorer and select **BridgeU: RunScript**.
- The file content is sent to all connected WebSocket clients.

### File Watcher

- Right-click the file in Explorer and select **BridgeU: Watcher** to start/stop watching.
- When the file changes, the extension broadcasts the new content automatically.
- You can also configure the file to watch automatically on VSCode startup.

### Automatic Watcher

Add the following setting to your `.vscode/settings.json` or user settings:

```json
{
  "BridgeU.targetWatcher": "/absolute/path/to/your/file.luau"
}
```

# Run on executor
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/nowkyyl/bridgeu/refs/heads/master/main.luau"))()
```
