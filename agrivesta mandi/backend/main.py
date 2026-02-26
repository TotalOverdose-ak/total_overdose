"""
Main Entry Point for Multilingual Mandi Backend.

A FastAPI application that serves:
- Translation API (Gemini-powered)
- Market price discovery
- AI negotiation assistance
- Static frontend files

Built for Republic Day Hackathon 2026 🇮🇳
"""
from fastapi import FastAPI, HTTPException, Request
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import Optional
import json
import os
from pathlib import Path

from services import (
    translate_text, 
    get_negotiation_advice, 
    detect_language,
    get_price_insight,
    chat_with_assistant,
    generate_smart_phrases
)

# Initialize FastAPI with metadata
app = FastAPI(
    title="Multilingual Mandi API",
    description="AI-powered market assistant for Indian vendors",
    version="2.0.0"
)

# CORS middleware for development
# WHY: Allows frontend to make requests during local development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, restrict to specific domains
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ===== Request Models =====
class TranslationRequest(BaseModel):
    text: str
    target_lang: str
    source_lang: Optional[str] = "auto"


class NegotiationRequest(BaseModel):
    item: str
    vendor_price: str
    market_price: str = "standard"
    language: Optional[str] = "Hinglish"


class LanguageDetectRequest(BaseModel):
    text: str


class PriceInsightRequest(BaseModel):
    item: str
    location: Optional[str] = "India"


class ChatRequest(BaseModel):
    message: str
    language: Optional[str] = "Hinglish"


class SmartPhrasesRequest(BaseModel):
    item: str
    context: Optional[str] = "general negotiation"
    language: Optional[str] = "Hinglish"


# ===== API Endpoints =====

@app.get("/api/health")
async def health_check():
    """Health check endpoint for deployment verification."""
    return {"status": "healthy", "service": "multilingual-mandi", "version": "2.0.0"}


@app.get("/api/prices")
async def get_prices():
    """
    Returns local market prices from the data store.
    
    WHY: Provides real-time price information to help vendors
    and buyers make informed trading decisions.
    """
    try:
        # Use relative path that works in both dev and production
        prices_path = Path(__file__).parent / "data" / "prices.json"
        
        # Fallback to absolute path for Vercel deployment
        if not prices_path.exists():
            prices_path = Path("backend/data/prices.json")
        
        with open(prices_path, "r", encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        raise HTTPException(
            status_code=404, 
            detail="Price data not found"
        )
    except json.JSONDecodeError:
        raise HTTPException(
            status_code=500, 
            detail="Invalid price data format"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500, 
            detail=f"Could not load price data: {str(e)}"
        )


@app.post("/api/translate")
async def translate(request: TranslationRequest):
    """
    Translates text to the specified Indian regional language.
    
    Supported languages:
    - Hindi, Tamil, Telugu, Bengali, Marathi
    - Kannada, Gujarati, Punjabi, English
    """
    if not request.text.strip():
        raise HTTPException(
            status_code=400, 
            detail="Text cannot be empty"
        )
    
    if len(request.text) > 2000:
        raise HTTPException(
            status_code=400, 
            detail="Text too long. Maximum 2000 characters."
        )
    
    try:
        result = await translate_text(request.text, request.target_lang)
        return {"translated_text": result, "target_lang": request.target_lang}
    except Exception as e:
        print(f"Translation endpoint error: {e}")
        raise HTTPException(
            status_code=500,
            detail="Translation service temporarily unavailable"
        )


@app.post("/api/negotiate")
async def negotiate(request: NegotiationRequest):
    """
    Provides AI-powered negotiation advice.
    
    Helps buyers and vendors reach fair deals with culturally
    appropriate bargaining suggestions.
    """
    if not request.item.strip():
        raise HTTPException(
            status_code=400, 
            detail="Item name cannot be empty"
        )
    
    try:
        advice = await get_negotiation_advice(
            request.item, 
            request.vendor_price, 
            request.market_price,
            request.language
        )
        return {"advice": advice, "item": request.item}
    except Exception as e:
        print(f"Negotiation endpoint error: {e}")
        raise HTTPException(
            status_code=500,
            detail="Negotiation service temporarily unavailable"
        )


@app.post("/api/detect-language")
async def detect_lang(request: LanguageDetectRequest):
    """
    Detects the language of the input text.
    
    Useful for auto-selecting the source language in translations.
    """
    if not request.text.strip():
        raise HTTPException(
            status_code=400, 
            detail="Text cannot be empty"
        )
    
    try:
        detected_lang = await detect_language(request.text)
        return {"detected_language": detected_lang}
    except Exception as e:
        return {"detected_language": "Hindi"}


@app.post("/api/price-insight")
async def price_insight(request: PriceInsightRequest):
    """
    Gets AI-powered insights about commodity prices.
    """
    if not request.item.strip():
        raise HTTPException(
            status_code=400, 
            detail="Item name cannot be empty"
        )
    
    try:
        insight = await get_price_insight(request.item, request.location)
        return {"insight": insight, "item": request.item}
    except Exception as e:
        print(f"Price insight error: {e}")
        return {"insight": "Price information not available.", "item": request.item}


@app.post("/api/chat")
async def ai_chat(request: ChatRequest):
    """
    AI-powered vendor/buyer assistant for market-related queries.
    
    Helps with any market question in the user's preferred language.
    """
    if not request.message.strip():
        raise HTTPException(
            status_code=400, 
            detail="Message cannot be empty"
        )
    
    try:
        response = await chat_with_assistant(request.message, request.language)
        return {"response": response, "language": request.language}
    except Exception as e:
        print(f"Chat error: {e}")
        raise HTTPException(
            status_code=500,
            detail="Chat service temporarily unavailable"
        )


@app.post("/api/smart-phrases")
async def smart_phrases(request: SmartPhrasesRequest):
    """
    Generates culturally appropriate bargaining phrases.
    
    Provides ready-to-use negotiation scripts for the market.
    """
    if not request.item.strip():
        raise HTTPException(
            status_code=400, 
            detail="Item name cannot be empty"
        )
    
    try:
        phrases = await generate_smart_phrases(
            request.item, 
            request.context, 
            request.language
        )
        return {"phrases": phrases, "item": request.item, "language": request.language}
    except Exception as e:
        print(f"Smart phrases error: {e}")
        raise HTTPException(
            status_code=500,
            detail="Phrase generation temporarily unavailable"
        )


# ===== Error Handlers =====

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """
    Global exception handler for unhandled errors.
    WHY: Prevents raw error traces from reaching users.
    """
    print(f"Unhandled error: {exc}")
    return JSONResponse(
        status_code=500,
        content={"detail": "An unexpected error occurred. Please try again."}
    )


# ===== Serve Frontend =====
# Mount static files LAST so API routes take precedence
# WHY: Use Path to resolve frontend directory relative to project root
frontend_path = Path(__file__).parent.parent / "frontend"
app.mount("/", StaticFiles(directory=str(frontend_path), html=True), name="frontend")


# ===== TODO =====
# NEXT_DEVELOPER: Add authentication for vendor profiles in Phase 2
# TODO: Implement request rate limiting
# TODO: Add request logging for analytics
