import * as vscode from "vscode";
import sendContent from "../sendContent";

export default async (resource: vscode.Uri) => {
    if (!resource) { return vscode.window.showInformationMessage("No file selected"); }

    const ext = resource.fsPath.slice(resource.fsPath.lastIndexOf(".")).toLocaleLowerCase();
    if (![".lua", ".luau"].includes(ext)) { return vscode.window.showInformationMessage("Invalid fale extension"); }

    try {
        const file = await vscode.workspace.openTextDocument(resource);
        const content = file.getText();
        const fileName = resource.fsPath.split(/[/\\]/).pop() || "Unknown";

        sendContent(fileName, content);
    } catch (err: any) {
        vscode.window.showErrorMessage(`Failed to open file: ${err.message}`);
    }
};
