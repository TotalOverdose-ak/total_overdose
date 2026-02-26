/**
 * Multilingual Mandi - Enhanced Frontend Logic
 * 
 * Features:
 * - Voice recognition with visual waveform
 * - Text-to-speech for translations
 * - Toast notification system
 * - Live price ticker animations
 * - Smooth loading states
 * - Negotiation in multiple languages
 * 
 * WHY: Modular, maintainable code for a polished user experience.
 */

// ===== CONFIGURATION =====
const API_BASE = ''; // Empty for same-origin, or set to your API URL

// ===== DOM REFERENCES =====
const DOM = {
    // Language selector
    globalLangBtn: document.getElementById('globalLangBtn'),
    langDropdown: document.getElementById('langDropdown'),
    currentLangFlag: document.getElementById('currentLangFlag'),
    currentLangName: document.getElementById('currentLangName'),

    // Translator
    sourceLang: document.getElementById('sourceLang'),
    targetLang: document.getElementById('targetLang'),
    swapLangsBtn: document.getElementById('swapLangsBtn'),
    inputText: document.getElementById('inputText'),
    micBtn: document.getElementById('micBtn'),
    translateBtn: document.getElementById('translateBtn'),
    voiceVisualizer: document.getElementById('voiceVisualizer'),
    translationOutput: document.getElementById('translationOutput'),
    translatedText: document.getElementById('translatedText'),
    speakBtn: document.getElementById('speakBtn'),
    copyBtn: document.getElementById('copyBtn'),

    // Price ticker
    tickerTrack: document.getElementById('tickerTrack'),
    priceList: document.getElementById('priceList'),

    // Negotiation
    negItem: document.getElementById('negItem'),
    negPrice: document.getElementById('negPrice'),
    negLang: document.getElementById('negLang'),
    negBtn: document.getElementById('negBtn'),
    negAdvice: document.getElementById('negAdvice'),
    negAdviceText: document.getElementById('negAdviceText'),

    // AI Chat
    chatMessages: document.getElementById('chatMessages'),
    chatInput: document.getElementById('chatInput'),
    chatSendBtn: document.getElementById('chatSendBtn'),
    chatLang: document.getElementById('chatLang'),

    // Toast
    toastContainer: document.getElementById('toastContainer')
};

// ===== CURRENT STATE =====
let currentTargetLang = 'Hindi';
let isListening = false;
let recognition = null;

// ===== EMOJI MAPPING FOR ITEMS =====
const itemEmojis = {
    'Tomato': '🍅',
    'Potato': '🥔',
    'Onion': '🧅',
    'Carrot': '🥕',
    'Cauliflower': '🥦',
    'Cabbage': '🥬',
    'Spinach': '🥬',
    'Brinjal': '🍆',
    'Capsicum': '🫑',
    'Cucumber': '🥒',
    'Garlic': '🧄',
    'Ginger': '🫚',
    'Green Chilli': '🌶️',
    'Banana': '🍌',
    'Apple': '🍎',
    'Mango': '🥭',
    'Rice': '🍚',
    'Wheat': '🌾',
    'default': '🥗'
};

// ===== TOAST NOTIFICATION SYSTEM =====
function showToast(message, type = 'info', duration = 4000) {
    const icons = {
        success: 'fa-check-circle',
        error: 'fa-exclamation-circle',
        info: 'fa-info-circle'
    };

    const toast = document.createElement('div');
    toast.className = `toast toast--${type}`;
    toast.innerHTML = `
        <i class="fas ${icons[type]} toast-icon"></i>
        <span class="toast-message">${message}</span>
        <button class="toast-close" aria-label="Close">
            <i class="fas fa-times"></i>
        </button>
    `;

    DOM.toastContainer.appendChild(toast);

    // Close button
    toast.querySelector('.toast-close').onclick = () => removeToast(toast);

    // Auto remove
    setTimeout(() => removeToast(toast), duration);
}

function removeToast(toast) {
    if (!toast.parentNode) return;
    toast.style.animation = 'slideIn 0.25s ease reverse';
    setTimeout(() => toast.remove(), 250);
}

// ===== LANGUAGE SELECTOR =====
if (DOM.globalLangBtn) {
    DOM.globalLangBtn.onclick = (e) => {
        e.stopPropagation();
        DOM.langDropdown.classList.toggle('active');
    };
}

// Close dropdown when clicking outside
document.addEventListener('click', (e) => {
    if (!e.target.closest('.lang-selector')) {
        DOM.langDropdown?.classList.remove('active');
    }
});

// Language option selection
document.querySelectorAll('.lang-option').forEach(option => {
    option.onclick = () => {
        const lang = option.dataset.lang;
        const flag = option.dataset.flag;

        // Update UI
        DOM.currentLangFlag.textContent = flag;
        DOM.currentLangName.textContent = lang;
        DOM.targetLang.value = lang;
        currentTargetLang = lang;

        // Update selected state
        document.querySelectorAll('.lang-option').forEach(o => o.classList.remove('selected'));
        option.classList.add('selected');

        // Close dropdown
        DOM.langDropdown.classList.remove('active');

        showToast(`Target language set to ${lang}`, 'success');
    };
});

// Swap languages
if (DOM.swapLangsBtn) {
    DOM.swapLangsBtn.onclick = () => {
        const source = DOM.sourceLang.value;
        const target = DOM.targetLang.value;

        if (source !== 'auto') {
            DOM.sourceLang.value = target;
            DOM.targetLang.value = source;
            currentTargetLang = source;

            // Animate button
            DOM.swapLangsBtn.style.transform = 'rotate(180deg)';
            setTimeout(() => DOM.swapLangsBtn.style.transform = '', 300);
        } else {
            showToast('Set a source language first to swap', 'info');
        }
    };
}

// ===== VOICE RECOGNITION =====
function initSpeechRecognition() {
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;

    if (!SpeechRecognition) {
        console.warn('Speech recognition not supported');
        return null;
    }

    const rec = new SpeechRecognition();
    rec.continuous = false;
    rec.interimResults = true;
    rec.maxAlternatives = 1;

    // Set language based on source selection
    const langCodes = {
        'auto': 'en-IN',
        'English': 'en-IN',
        'Hindi': 'hi-IN',
        'Tamil': 'ta-IN',
        'Telugu': 'te-IN',
        'Bengali': 'bn-IN',
        'Marathi': 'mr-IN',
        'Kannada': 'kn-IN',
        'Gujarati': 'gu-IN',
        'Punjabi': 'pa-IN'
    };

    rec.lang = langCodes[DOM.sourceLang?.value] || 'en-IN';

    rec.onstart = () => {
        isListening = true;
        updateMicUI(true);
        DOM.voiceVisualizer?.classList.add('active');
        showToast('🎤 Listening... Speak now!', 'info');
    };

    rec.onresult = (event) => {
        let transcript = '';
        for (let i = event.resultIndex; i < event.results.length; i++) {
            transcript += event.results[i][0].transcript;
        }
        DOM.inputText.value = transcript;
    };

    rec.onerror = (event) => {
        console.error('Speech recognition error:', event.error);
        stopListening();

        if (event.error === 'not-allowed') {
            showToast('Microphone access denied. Please enable in settings.', 'error');
        } else if (event.error === 'no-speech') {
            showToast('No speech detected. Please try again.', 'info');
        } else {
            showToast('Voice input failed. Please try again.', 'error');
        }
    };

    rec.onend = () => {
        stopListening();
    };

    return rec;
}

function updateMicUI(listening) {
    const micBtn = DOM.micBtn;
    if (!micBtn) return;

    if (listening) {
        micBtn.classList.add('listening');
        micBtn.innerHTML = '<i class="fas fa-stop"></i><span>Stop</span>';
    } else {
        micBtn.classList.remove('listening');
        micBtn.innerHTML = '<i class="fas fa-microphone"></i><span>Speak</span>';
    }
}

function startListening() {
    // Re-initialize to pick up current language setting
    recognition = initSpeechRecognition();

    if (!recognition) {
        showToast('Speech recognition not supported in this browser', 'error');
        return;
    }

    try {
        recognition.start();
    } catch (e) {
        console.error('Failed to start recognition:', e);
        showToast('Could not start voice input', 'error');
    }
}

function stopListening() {
    isListening = false;
    updateMicUI(false);
    DOM.voiceVisualizer?.classList.remove('active');

    if (recognition) {
        try {
            recognition.stop();
        } catch (e) { }
    }
}

if (DOM.micBtn) {
    DOM.micBtn.onclick = () => {
        if (isListening) {
            stopListening();
        } else {
            startListening();
        }
    };
}

// ===== TRANSLATION API =====
async function translate() {
    const text = DOM.inputText?.value.trim();
    const targetLang = DOM.targetLang?.value || currentTargetLang;

    if (!text) {
        showToast('Please enter text to translate', 'error');
        return;
    }

    // Update button state
    DOM.translateBtn.disabled = true;
    DOM.translateBtn.innerHTML = '<div class="loading-spinner"></div><span>Translating...</span>';

    try {
        const res = await fetch(`${API_BASE}/api/translate`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                text,
                target_lang: targetLang,
                source_lang: DOM.sourceLang?.value || 'auto'
            })
        });

        if (!res.ok) {
            const errorData = await res.json().catch(() => ({}));
            throw new Error(errorData.detail || 'Translation failed');
        }

        const data = await res.json();

        // Show output
        DOM.translatedText.textContent = data.translated_text;
        DOM.translationOutput.classList.add('visible');

        showToast(`✅ Translated to ${targetLang}!`, 'success');

    } catch (err) {
        console.error('Translation error:', err);
        showToast(`Translation failed: ${err.message}`, 'error');
    } finally {
        DOM.translateBtn.disabled = false;
        DOM.translateBtn.innerHTML = '<i class="fas fa-globe"></i><span>Translate</span>';
    }
}

if (DOM.translateBtn) {
    DOM.translateBtn.onclick = translate;
}

// Translate on Enter key (with Ctrl)
if (DOM.inputText) {
    DOM.inputText.onkeydown = (e) => {
        if (e.ctrlKey && e.key === 'Enter') {
            e.preventDefault();
            translate();
        }
    };
}

// ===== TEXT-TO-SPEECH =====
function speakText(text) {
    if (!('speechSynthesis' in window)) {
        showToast('Text-to-speech not supported', 'error');
        return;
    }

    // Cancel any ongoing speech
    speechSynthesis.cancel();

    const utterance = new SpeechSynthesisUtterance(text);

    // Map language names to speech synthesis codes
    const langCodes = {
        'Hindi': 'hi-IN',
        'Tamil': 'ta-IN',
        'Telugu': 'te-IN',
        'Bengali': 'bn-IN',
        'Marathi': 'mr-IN',
        'Kannada': 'kn-IN',
        'Gujarati': 'gu-IN',
        'Punjabi': 'pa-IN',
        'English': 'en-IN'
    };

    const targetLang = DOM.targetLang?.value || currentTargetLang;
    utterance.lang = langCodes[targetLang] || 'hi-IN';
    utterance.rate = 0.9;

    utterance.onstart = () => {
        DOM.speakBtn.innerHTML = '<i class="fas fa-volume-off"></i>';
    };

    utterance.onend = () => {
        DOM.speakBtn.innerHTML = '<i class="fas fa-volume-up"></i>';
    };

    utterance.onerror = () => {
        DOM.speakBtn.innerHTML = '<i class="fas fa-volume-up"></i>';
        showToast('Speech synthesis failed', 'error');
    };

    speechSynthesis.speak(utterance);
}

if (DOM.speakBtn) {
    DOM.speakBtn.onclick = () => {
        const text = DOM.translatedText?.textContent;
        if (text && text.length > 0) {
            speakText(text);
        } else {
            showToast('No translation to speak', 'info');
        }
    };
}

// ===== COPY TO CLIPBOARD =====
if (DOM.copyBtn) {
    DOM.copyBtn.onclick = async () => {
        const text = DOM.translatedText?.textContent;
        if (!text) {
            showToast('No translation to copy', 'info');
            return;
        }

        try {
            await navigator.clipboard.writeText(text);
            showToast('📋 Copied to clipboard!', 'success');

            // Visual feedback
            DOM.copyBtn.innerHTML = '<i class="fas fa-check"></i>';
            setTimeout(() => {
                DOM.copyBtn.innerHTML = '<i class="fas fa-copy"></i>';
            }, 1500);
        } catch (err) {
            showToast('Failed to copy', 'error');
        }
    };
}

// ===== PRICE DATA =====
let priceData = [];

async function fetchPrices() {
    try {
        const res = await fetch(`${API_BASE}/api/prices`);
        if (!res.ok) throw new Error('Failed to fetch prices');

        priceData = await res.json();
        renderPriceList();
        renderTicker();

    } catch (err) {
        console.error('Price fetch error:', err);
        if (DOM.priceList) {
            DOM.priceList.innerHTML = `
                <div class="price-item" style="justify-content: center; color: var(--text-muted);">
                    <i class="fas fa-exclamation-circle"></i>&nbsp; Failed to load prices
                </div>
            `;
        }
    }
}

function renderPriceList() {
    if (!DOM.priceList) return;

    DOM.priceList.innerHTML = priceData.map(item => {
        const emoji = itemEmojis[item.item] || itemEmojis.default;
        const trend = item.trend || 'stable';
        const trendIcon = trend === 'up' ? '↑' : trend === 'down' ? '↓' : '→';

        return `
            <div class="price-item">
                <div class="price-item-info">
                    <span class="price-item-emoji">${emoji}</span>
                    <div class="price-item-details">
                        <span class="price-item-name">${item.item}</span>
                        <span class="price-item-location">${item.location}</span>
                    </div>
                </div>
                <div class="price-item-value">
                    <span class="price-item-amount">₹${item.price}</span>
                    <span class="price-item-trend ${trend}">${trendIcon}</span>
                </div>
            </div>
        `;
    }).join('');
}

function renderTicker() {
    if (!DOM.tickerTrack) return;

    // Create ticker content (duplicate for seamless loop)
    const tickerContent = priceData.map(item => {
        const emoji = itemEmojis[item.item] || itemEmojis.default;
        const trend = item.trend || 'stable';
        const trendIcon = trend === 'up' ? '📈' : trend === 'down' ? '📉' : '➡️';

        return `
            <div class="ticker-item">
                <span class="ticker-item-name">${emoji} ${item.item}</span>
                <span class="ticker-item-price">₹${item.price}</span>
                <span class="ticker-item-location">${item.location}</span>
                <span class="ticker-item-trend ${trend}">${trendIcon}</span>
            </div>
            <span class="ticker-divider">•</span>
        `;
    }).join('');

    // Duplicate for seamless scrolling
    DOM.tickerTrack.innerHTML = tickerContent + tickerContent;
}

// ===== NEGOTIATION ASSISTANT =====
async function getNegotiation() {
    const item = DOM.negItem?.value.trim();
    const price = DOM.negPrice?.value.trim();
    const language = DOM.negLang?.value || 'Hinglish';

    if (!item) {
        showToast('Please enter the item name', 'error');
        return;
    }

    if (!price) {
        showToast('Please enter the asking price', 'error');
        return;
    }

    // Update button state
    DOM.negBtn.disabled = true;
    DOM.negBtn.innerHTML = '<div class="loading-spinner"></div><span>Thinking...</span>';

    try {
        const res = await fetch(`${API_BASE}/api/negotiate`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                item,
                vendor_price: price,
                market_price: 'standard',
                language: language
            })
        });

        if (!res.ok) {
            const errorData = await res.json().catch(() => ({}));
            throw new Error(errorData.detail || 'Negotiation advice failed');
        }

        const data = await res.json();

        // Show advice
        DOM.negAdviceText.textContent = data.advice;
        DOM.negAdvice.classList.add('visible');

        showToast('💡 Negotiation tip ready!', 'success');

    } catch (err) {
        console.error('Negotiation error:', err);
        showToast(`Failed to get advice: ${err.message}`, 'error');
    } finally {
        DOM.negBtn.disabled = false;
        DOM.negBtn.innerHTML = '<i class="fas fa-lightbulb"></i><span>Get Advice</span>';
    }
}

if (DOM.negBtn) {
    DOM.negBtn.onclick = getNegotiation;
}

// Negotiate on Enter key
if (DOM.negPrice) {
    DOM.negPrice.onkeydown = (e) => {
        if (e.key === 'Enter') {
            e.preventDefault();
            getNegotiation();
        }
    };
}

// ===== KEYBOARD SHORTCUTS =====
document.addEventListener('keydown', (e) => {
    // Ctrl+M to toggle microphone
    if (e.ctrlKey && e.key === 'm') {
        e.preventDefault();
        DOM.micBtn?.click();
    }

    // Escape to close dropdown
    if (e.key === 'Escape') {
        DOM.langDropdown?.classList.remove('active');
    }
});

// ===== AI CHAT ASSISTANT =====
async function sendChatMessage() {
    const message = DOM.chatInput?.value.trim();
    const language = DOM.chatLang?.value || 'Hinglish';

    if (!message) {
        showToast('Please type a message', 'info');
        return;
    }

    // Add user message to chat
    addChatMessage(message, 'user');
    DOM.chatInput.value = '';

    // Show loading indicator
    const loadingDiv = document.createElement('div');
    loadingDiv.className = 'chat-loading';
    loadingDiv.innerHTML = `
        <div class="chat-loading-dot"></div>
        <div class="chat-loading-dot"></div>
        <div class="chat-loading-dot"></div>
    `;
    DOM.chatMessages.appendChild(loadingDiv);
    scrollChatToBottom();

    try {
        const res = await fetch(`${API_BASE}/api/chat`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                message,
                language
            })
        });

        // Remove loading indicator
        loadingDiv.remove();

        if (!res.ok) {
            const errorData = await res.json().catch(() => ({}));
            throw new Error(errorData.detail || 'Chat failed');
        }

        const data = await res.json();
        addChatMessage(data.response, 'ai');

    } catch (err) {
        console.error('Chat error:', err);
        loadingDiv.remove();
        addChatMessage('Sorry, I couldn\'t process that. Please try again!', 'ai');
        showToast(`Chat error: ${err.message}`, 'error');
    }
}

function addChatMessage(text, type) {
    // Remove welcome message if it exists
    const welcome = DOM.chatMessages?.querySelector('.chat-welcome');
    if (welcome) {
        welcome.remove();
    }

    const msgDiv = document.createElement('div');
    msgDiv.className = `chat-message chat-message--${type}`;
    msgDiv.textContent = text;
    DOM.chatMessages?.appendChild(msgDiv);
    scrollChatToBottom();
}

function scrollChatToBottom() {
    if (DOM.chatMessages) {
        DOM.chatMessages.scrollTop = DOM.chatMessages.scrollHeight;
    }
}

// Chat button click handler
if (DOM.chatSendBtn) {
    DOM.chatSendBtn.onclick = sendChatMessage;
}

// Chat Enter key handler
if (DOM.chatInput) {
    DOM.chatInput.onkeydown = (e) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendChatMessage();
        }
    };
}

// ===== INITIALIZATION =====
function init() {
    console.log('🏪 Multilingual Mandi v2.1 initialized');

    // Fetch prices on load
    fetchPrices();

    // Show welcome toast after a short delay
    setTimeout(() => {
        showToast('Welcome to Multilingual Mandi! 🇮🇳', 'info');
    }, 800);
}

// Start the app when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
} else {
    init();
}

// ===== TODO =====
// TODO: Add caching for translations to reduce API calls
// TODO: Implement offline mode with service worker
// TODO: Add voice command support ("translate to Hindi")
// NEXT_DEVELOPER: Consider adding a chat-style history for translations
