"""
DOTWEB DevSecOps Pipeline — Sample Application
This simple Flask app is the target for all security scans in the pipeline.
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
        "company": "DOTWEB Enterprise & Business Applications"
    })
 
 
@app.route("/health")
def health():
    return jsonify({"status": "ok"}), 200
 
 
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)
