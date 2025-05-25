import * as vscode from "vscode";
import { setupWebSocketServer, getWebSocketClients } from "./websocket";
import commands from "./registerCommands";

export function activate(context: vscode.ExtensionContext) {
	setupWebSocketServer();
	commands(context);
}

export function deactivate() {
	getWebSocketClients().forEach(client => client.close());
}
