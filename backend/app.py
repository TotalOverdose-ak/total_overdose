from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import requests

app = Flask(__name__)
CORS(app)  # Allow Flutter app to call this

# ── OpenRouter Configuration ──────────────────────────────────────────────────
# Set these environment variables before running:
#   set OPENROUTER_API_KEY=sk-or-v1-your-key-here
#   set AI_MODEL=google/gemini-2.0-flash-exp
OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY", "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")
AI_MODEL = os.getenv("AI_MODEL", "deepseek/deepseek-r1:free")
OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions"


@app.route("/")
def index():
    return jsonify({
        "status": "ok",
        "message": "Agri Vista AI Proxy is running!",
        "model": AI_MODEL,
    })


@app.route("/api/chat", methods=["POST"])
def api_chat():
    """
    Simple AI chat endpoint for the Flutter app.
    
    Request body:
        {
            "messages": [
                {"role": "system", "content": "..."},
                {"role": "user", "content": "Hello"}
            ],
            "temperature": 0.7,    // optional
            "max_tokens": 512      // optional
        }
    
    Response:
        {
            "success": true,
            "content": "AI response text here"
        }
    """
    try:
        data = request.json
        messages = data.get("messages", [])
        temperature = data.get("temperature", 0.7)
        max_tokens = data.get("max_tokens", 512)

        if not messages:
            return jsonify({"success": False, "error": "No messages provided"}), 400

        if not OPENROUTER_API_KEY:
            return jsonify({"success": False, "error": "API key not configured"}), 500

        # Call OpenRouter
        response = requests.post(
            OPENROUTER_URL,
            headers={
                "Authorization": f"Bearer {OPENROUTER_API_KEY}",
                "Content-Type": "application/json",
            },
            json={
                "model": AI_MODEL,
                "messages": messages,
                "temperature": temperature,
                "max_tokens": max_tokens,
            },
            timeout=30,
        )

        if response.status_code != 200:
            print(f"OpenRouter error: {response.status_code} {response.text}")
            return jsonify({
                "success": False,
                "error": f"AI API error: {response.status_code}",
            }), response.status_code

        result = response.json()
        content = result["choices"][0]["message"]["content"]

        return jsonify({"success": True, "content": content})

    except Exception as e:
        print(f"Error in /api/chat: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500


if __name__ == "__main__":
    port = int(os.getenv("PORT", 5000))
    print(f"🚀 Agri Vista AI Proxy starting on port {port}")
    print(f"📡 Model: {AI_MODEL}")
    print(f"🔑 API Key: {'✅ Set' if OPENROUTER_API_KEY else '❌ NOT SET'}")
    app.run(host="0.0.0.0", port=port, debug=True)
