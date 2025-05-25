import * as vscode from "vscode";

const outputChannels = new Map<string, vscode.OutputChannel>();
export function getOutputChannel(fileName: string): vscode.OutputChannel {
    if (!outputChannels.has(fileName)) {
        const channel = vscode.window.createOutputChannel(`BridgeU - ${fileName}`);
        outputChannels.set(fileName, channel);
    }
    return outputChannels.get(fileName)!;
}

export function logMessage(fileName: string, message: string) {
    const channel = getOutputChannel(fileName);
    channel.appendLine(message);
    channel.show(true);
}

export function disposeOutputChannel(fileName: string) {
    const channel = outputChannels.get(fileName);
    if (channel) {
        channel.dispose();
        outputChannels.delete(fileName);
    }
}

export function disposeOutputChannels() {
    outputChannels.forEach((channel) => channel.dispose());
    outputChannels.clear();
}