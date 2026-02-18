#!/usr/bin/env python3
"""
Simple HTTP server for testing Agent Trace demo.

This serves the HTML with proper URLs so Sentry's suspect commits work correctly.
Stack traces will show relative paths that Sentry can map to GitHub.
"""

import http.server
import socketserver
import os

PORT = 8000
DIRECTORY = "."

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def end_headers(self):
        # Add CORS headers for local development
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        super().end_headers()

if __name__ == '__main__':
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        print(f"🚀 Serving Agent Trace Demo at http://localhost:{PORT}")
        print(f"📂 Directory: {os.getcwd()}")
        print(f"")
        print(f"Open: http://localhost:{PORT}/simple-web-test/index.html")
        print(f"")
        print(f"Press Ctrl+C to stop")
        httpd.serve_forever()
