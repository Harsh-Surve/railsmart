from flask import Flask, request, jsonify
app = Flask(__name__)

@app.route('/')
def index():
    return 'RailSmart AI service running ✅'

@app.route('/voice/recognize', methods=['POST'])
def recognize():
    data = request.json or {}
    transcript = data.get('transcript', '')
    # VERY simple parser example (for demo)
    if 'book' in transcript.lower():
        return jsonify({'intent':'book_ticket', 'slots':{}}), 200
    return jsonify({'intent':'unknown'}), 200

if __name__ == '__main__':
    app.run(port=6000, debug=True)
