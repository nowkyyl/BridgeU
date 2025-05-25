import * as assert from 'assert';
import * as vscode from 'vscode';
import WebSocket from 'ws';

suite('BridgeU Extension Test Suite', () => {
	vscode.window.showInformationMessage('Starting BridgeU Extension Tests');

	test('Sample test', () => {
		assert.strictEqual(-1, [1, 2, 3].indexOf(5));
		assert.strictEqual(-1, [1, 2, 3].indexOf(0));
	});
});
