import * as vscode from "vscode";
import sendContent from "../sendContent";

const fileWatchers = new Map<string, vscode.Disposable>();
export function watchFile(resource: vscode.Uri) {
    if (!resource) { return vscode.window.showInformationMessage("No file selected"); }

    const ext = resource.fsPath.slice(resource.fsPath.lastIndexOf(".")).toLowerCase();
    if (![".lua", ".luau"].includes(ext)) { return vscode.window.showInformationMessage("Invalid file extension"); }

    if (fileWatchers.has(resource.fsPath)) { return vscode.window.showWarningMessage(`Already watching: ${resource.fsPath}`); }

    vscode.commands.executeCommand("setContext", "bridgeu.isWatching", true);

    fileWatchers.set(resource.fsPath, vscode.workspace.onDidSaveTextDocument(async (document) => {
        if (document.uri.fsPath !== resource.fsPath) { return; }

        try {
            const content = document.getText();
            const fileName = resource.fsPath.split(/[/\\]/).pop() || "Unknown";

            sendContent(fileName, content);
        } catch (err: any) {
            vscode.window.showErrorMessage(`Failed to read file: ${err.message}`);
        }
    }));
    vscode.window.showInformationMessage(`Watching for save: ${resource.fsPath}`);
}

export function stopWatchingFile(resource: vscode.Uri) {
    if (!resource) { return vscode.window.showInformationMessage("No file selected"); }

    const watcher = fileWatchers.get(resource.fsPath);
    if (!watcher) { return vscode.window.showWarningMessage(`File is not being watched: ${resource.fsPath}`); }

    watcher.dispose();
    fileWatchers.delete(resource.fsPath);

    vscode.commands.executeCommand("setContext", "bridgeu.isWatching", false);
    vscode.window.showInformationMessage(`Stopped watching ${resource.fsPath}`);
}