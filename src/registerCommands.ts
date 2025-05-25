import * as vscode from "vscode";
import commands from "./commands";

export default (context: vscode.ExtensionContext) => {
    context.subscriptions.push(
        vscode.commands.registerCommand("bridgeu.runScript", commands.runScript),
        vscode.commands.registerCommand("bridgeu.watchFile", commands.watchFile),
        vscode.commands.registerCommand("bridgeu.stopWatchingFile", commands.stopWatchingFile),
        vscode.commands.registerCommand("bridgeu.runScriptFromFile", commands.runScriptFromFile)
    );
};