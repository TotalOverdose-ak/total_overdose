# 🏪 Multilingual Mandi (AI-Powered)

> **Republic Day Hackathon 2026 Winner Candidate** 🇮🇳
> Breaking language barriers for Indian local market vendors with Gemini AI.

![Multilingual Mandi Banner](https://via.placeholder.com/1200x400/050508/ff6b35?text=Multilingual+Mandi+AI)

## 🚀 Overview

**Multilingual Mandi** is a progressive web app designed to empower local vendors and buyers in India's diverse linguistic landscape. It uses **Google's Gemini 3 Flash** model to provide real-time translation, negotiation assistance, and market insights.

### Key Features

- **🎙️ Voice-to-Voice Translation**: Instant translation between 9+ Indian languages (Hindi, Tamil, Telugu, Bengali, etc.).
- **🤝 AI Bargain Assistant**: Culturally aware negotiation tips in "Hinglish" and regional languages to help you get the best deal.
- **🤖 AI Market Chat**: A conversational assistant that answers questions about market timings, seasonal produce, and storage tips.
- **� Live Price Ticker**: Real-time updates on commodity prices from major Mandis across India.
- **📱 Mobile-First Design**: Cyberpunk-inspired, high-contrast UI optimized for outdoor market usage.

---

## 🛠️ Tech Stack

- **Frontend**: Vanilla JS, HTML5, CSS3 (Glassmorphism UI)
- **Backend**: FastAPI (Python)
- **AI Engine**: Google Gemini API (`gemini-3-flash-preview`)
- **SDK**: `google-genai` (Async implementation)

---

## ⚡ Setup & Run

### Prerequisites
- Python 3.9+
- Google Gemini API Key

### Installation

1. **Clone the repo**
   ```bash
   git clone https://github.com/yourusername/multilingual-mandi.git
   cd multilingual-mandi
   ```

2. **Set up Backend**
   ```bash
   cd backend
   pip install -r ../requirements.txt
   ```

3. **Configure Environment**
   Create a `.env` file in the root directory:
   ```env
   GEMINI_API_KEY=your_api_key_here
   ```

4. **Run the Server**
   ```bash
   # Make sure you are in the 'backend' directory
   python -m uvicorn main:app --reload --port 8000
   ```

5. **Open the App**
   Visit `http://localhost:8000` in your browser.

---

## 🤖 AI Capabilities

We leverage the full power of **Gemini 3 Flash**:

1. **Contextual Translation**: Understands market slang and specific trade terms.
2. **Sentiment Analysis**: Detects negotiation tone to provide appropriate advice.
3. **Cultural Nuance**: Generates responses using respectful terms (e.g., "Bhaiya", "Anna") appropriate for each language.
4. **Complex Query Reasoning**: The AI Chat can synthesize advice balancing quality vs. price.

---

## � Project Structure

```
/multilingual-mandi
├── /.kiro               # Hackathon submission assets
├── /backend
│   ├── main.py          # FastAPI application & endpoints
│   ├── services.py      # Gemini AI integration logic
│   └── /data            # Static price data
├── /frontend
│   ├── index.html       # Main UI structure
│   ├── app.js           # Frontend logic & API calls
│   └── styles.css       # Cyberpunk/Glassmorphism styles
├── .env                 # API keys (not committed)
└── requirements.txt     # Python dependencies
```

---

## 🔮 Future Roadmap

- [ ] **Image Recognition**: Snap a photo of a vegetable to get quality analysis.
- [ ] **Voice Shopping List**: Create lists via voice commands.
- [ ] **Vendor Profiles**: Digital identity for street vendors.

---

Made with ❤️ for **Republic Day Hackathon 2026**
