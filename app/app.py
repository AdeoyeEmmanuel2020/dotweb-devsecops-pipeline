"""
DOTWEB DevSecOps Pipeline - Sample Application
Target application for the security scanning pipeline.
"""

from flask import Flask, jsonify
import os

app = Flask(__name__)


@app.route("/")
def index():
    return jsonify({
        "service": "DOTWEB Sample API",
        "version": "1.0.0",
        "status": "healthy",
        "company": "DOTWEB Enterprise and Business Applications"
    })


@app.route("/health")
def health():
    return jsonify({"status": "ok"}), 200


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    # Host read from environment variable - not hardcoded to 0.0.0.0
    host = os.environ.get("HOST", "127.0.0.1")
    app.run(host=host, port=port)
