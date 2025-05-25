import * as vscode from "vscode";
import sendContent from "../sendContent";

export default async () => {
    const editor = vscode.window.activeTextEditor;
    if (!editor) { return vscode.window.showWarningMessage("No active editor found"); }
    if (editor.document.uri.scheme !== "file") { return vscode.window.showWarningMessage("Invalid editor"); }

    const content = editor.document.getText();
    const fileName = editor.document.fileName.split(/[/\\]/).pop() || "Unknown";
    sendContent(fileName, content);
};