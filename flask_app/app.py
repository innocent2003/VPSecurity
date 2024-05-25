from flask import Flask, request, jsonify
import os
from lxml import etree

app = Flask(__name__)

# Command Injection Vulnerability
@app.route('/vulnerable', methods=['GET'])
def vulnerable():
    param = request.args.get('param')
    os.system(f'echo {param}')  # Vulnerable to command injection
    return f'Executed command with param: {param}'

# Overly permissive route demonstrating a lack of access control
@app.route('/admin', methods=['GET'])
def admin():
    auth = request.authorization
    if not auth or auth.username != 'admin' or auth.password != 'secret':
        return jsonify({"message": "Authentication required"}), 401
    return "Admin access granted"

# XML External Entity (XXE) Vulnerability
@app.route('/upload', methods=['POST'])
def upload():
    xml = request.data
    parser = etree.XMLParser(resolve_entities=False)
    tree = etree.fromstring(xml, parser=parser)  # XXE protection
    return "XML processed"

# Log storage simulation
@app.route('/store_log', methods=['POST'])
def store_log():
    log_data = request.json.get('log')
    # Simulate storing logs in S3 (actual S3 implementation would be more complex)
    return jsonify({"status": "Log stored", "log": log_data})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
