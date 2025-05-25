import * as vscode from "vscode";
import { logMessage, disposeOutputChannel } from "./outputChannels";
import WebSocket, { WebSocketServer } from "ws";

let wsServer: WebSocketServer | null = null;
const webSocketsClients: Map<WebSocket, string> = new Map();
export function setupWebSocketServer() {
    wsServer = new WebSocketServer({ port: 8080 });

    wsServer.on("connection", (wsClient) => {
        wsClient.on("message", (msg: WebSocket.RawData | string) => {
            try {
                const str = msg.toString();
                vscode.window.showInformationMessage(str);

                if (str.startsWith("Output:")) {
                    const jsonStr = str.slice(7);
                    const data = JSON.parse(jsonStr);

                    const fileName = data.fileName || "Unknown";
                    const error = data.error || "Unknown error";

                    logMessage(fileName, error);
                    webSocketsClients.set(wsClient, fileName);
                }
            } catch (err) {
                vscode.window.showErrorMessage(`Malformed message: ${(err as Error).message}`);
            }
        });

        wsClient.on("close", () => {
            const fileName = webSocketsClients.get(wsClient);
            webSocketsClients.delete(wsClient);

            if (fileName) {
                disposeOutputChannel(fileName);
                vscode.window.showInformationMessage(`WebSocket closed for file: ${fileName}`);
            } else {
                vscode.window.showInformationMessage("WebSocket closed");
            }
        });

        wsClient.on("error", (err) => {
            vscode.window.showErrorMessage(`WebSocket Error: ${err.stack ?? err.message}`);
        });
    });
}

export function getWebSocketClients(): WebSocket[] {
    return Array.from(webSocketsClients.keys());
}