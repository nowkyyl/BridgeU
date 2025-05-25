import * as assert from 'assert';
import * as vscode from 'vscode';
import WebSocket from 'ws';

suite('BridgeU Extension Test Suite', () => {
	vscode.window.showInformationMessage('Starting BridgeU Extension Tests');

	test('Sample test', () => {
		assert.strictEqual(-1, [1, 2, 3].indexOf(5));
		assert.strictEqual(-1, [1, 2, 3].indexOf(0));
	});

	test('WebSocket connection and send message', function(done) {
		this.timeout(50000);

		const ws = new WebSocket('ws://localhost:8080/');

		ws.on('open', () => {
			const message = JSON.stringify({
				fileName: "test.lua",
				content: 'print("Hello from test")'
			});
			ws.send(`Output:${message}`);
		});

		ws.on('message', (data) => {
			done();
		});

		ws.on('error', (err) => {
			done(err);
		});
	});
});
