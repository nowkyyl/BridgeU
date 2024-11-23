# WebSocket Code Executor
*This extension allows you to send Lua code from VS Code to WebSocket clients.*
### **Support for all exploits that contain WebSocket!**

## Features
  - **Send code to clients**: Send Lua code from the active editor to connected WebSocket clients.
  - **Right-click menu**: Right-click on a Lua file in the Explorer to send its content to clients.
  - **Show clients**: Press `Ctrl+Shift+P` and search for **"Socket Bridge: Show all clients"** to view the list of connected clients.
  - **Status bar button**: A button in the status bar to execute the code in the current editor.
  - **Output Error**: Displays the error of the code you executed.

## Installation
  1. Download the `.vsix` file for the extension.
  2. Open Visual Studio Code.
  3. Go to the Extensions view (`Ctrl+Shift+X`).
  4. Click on the three-dot menu in the top-right corner.
  5. Select **"Install from VSIX..."**.
  6. Choose the downloaded `.vsix` file.

![image](https://github.com/user-attachments/assets/7c17b787-a281-49d2-885d-c555c48763cb)

## Usage
  - **Send code from the editor**: Click the **"Run"** button in the status bar.
  - **Send code from a file**: Right-click a Lua file in the Explorer and choose **"Execute File in WebSocket"**.
  - **View connected clients**: Use the **"Socket Bridge: Show all clients"** command to see all connected WebSocket clients.
  - **Execute this code in your executor (exploit) or place it in the folder `autoexec`**: 
    ```lua
    loadstring(game:HttpGet("https://raw.githubusercontent.com/nowkyyl/BridgeU/refs/heads/main/main.lua"))()
    ```

![image](https://github.com/user-attachments/assets/74b13639-7167-4348-a659-9e525bb7a39d)
