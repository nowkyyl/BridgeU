import * as vscode from "vscode";
import { getWebSocketClients } from "./websocket";

export default (fileName: string, content: string) => {
    const webSocketsClients = getWebSocketClients();

    webSocketsClients.forEach(wsClient => wsClient.send(JSON.stringify({ fileName, content })));
    vscode.window.showInformationMessage(`Sent to ${webSocketsClients.length} WebSockets`);
};
