# Implementation Plan: Multilingual Mandi

## Overview

This implementation plan breaks down the Multilingual Mandi platform into discrete, incremental coding tasks. The approach prioritizes core functionality (P0 features: Translation, Voice Input, Price Lookup) first, followed by the Negotiation Assistant (P1). Each task builds on previous work, with property-based tests integrated throughout to catch errors early.

The implementation follows a bottom-up approach: core services → API layer → frontend UI → integration → deployment configuration.

## Tasks

- [ ] 1. Set up project structure and dependencies
  - Create directory structure (api/, public/, tests/)
  - Create requirements.txt with FastAPI, Pydantic, google-generativeai, hypothesis, pytest
  - Create package.json (minimal, no build tools) with fast-check for frontend testing
  - Create .env.example with GEMINI_API_KEY placeholder
  - Create .gitignore (exclude .env, __pycache__, node_modules)
  - _Requirements: 9.3, 10.1, 10.5_

- [ ] 2. Implement data models and validation
  - [ ] 2.1 Create Pydantic models for all API requests and responses
    - TranslationRequest, TranslationResponse
    - PriceRequest, PriceData, PriceResponse
    - NegotiationRequest, PriceComparison, NegotiationResponse
    - Include validators for language codes, price ranges, text validation
    - _Requirements: 1.5, 3.1, 4.1_

  - [ ]* 2.2 Write property test for price range invariant
    - **Property 6: Price Range Invariant**
    - **Validates: Requirements 3.1**
    - Generate random price data and verify min ≤ avg ≤ max always holds
    - _Requirements: 3.1_

  - [ ]* 2.3 Write unit tests for model validation
    - Test empty text rejection
    - Test invalid language codes
    - Test negative prices
    - Test same source/target language
    - _Requirements: 1.5, 7.3_

- [ ] 3. Implement in-memory cache system
  - [ ] 3.1 Create InMemoryCache class with LRU eviction
    - Implement get(), set(), is_fresh() methods
    - Add timestamp tracking for cache entries
    - Implement LRU eviction when cache is full (max 100 entries)
    - _Requirements: 8.1, 8.2, 8.3, 8.4_

  - [ ]* 3.2 Write property test for cache consistency
    - **Property 8: Cache Consistency**
    - **Validates: Requirements 3.5**
    - Generate random commodity, cache it, query multiple times, verify identical results
    - _Requirements: 3.5, 8.2_

  - [ ]* 3.3 Write property test for cache freshness
    - **Property 9: Cache Freshness Serving**
    - **Validates: Requirements 8.2, 8.3**
    - Verify fresh cached data is served without API calls
    - _Requirements: 8.2, 8.3_

  - [ ]* 3.4 Write property test for LRU eviction
    - **Property 10: LRU Cache Eviction**
    - **Validates: Requirements 8.4**
    - Fill cache beyond max size, verify oldest entries are evicted
    - _Requirements: 8.4_

  - [ ]* 3.5 Write unit tests for cache edge cases
    - Test cache with stale entries
    - Test cache eviction at exactly max_size
    - Test cache with zero TTL
    - _Requirements: 8.1, 8.4_

- [ ] 4. Checkpoint - Ensure cache tests pass
  - Run pytest tests/property/test_cache_properties.py and tests/unit/test_cache.py
  - Verify all cache properties hold
  - Ask the user if questions arise

- [ ] 5. Implement Translation Service
  - [ ] 5.1 Create TranslationService class with Gemini API integration
    - Implement translate() method with API calls
    - Add validate_language() and sanitize_input() helpers
    - Implement retry logic with exponential backoff (3 retries)
    - Add 5-second timeout for requests
    - Implement error handling for rate limits, network failures, malformed responses
    - _Requirements: 1.1, 1.2, 1.4, 1.5, 7.1, 7.2, 7.3, 7.4, 7.5_

  - [ ]* 5.2 Write property test for language pair completeness
    - **Property 1: Translation Language Pair Completeness**
    - **Validates: Requirements 1.1, 1.3**
    - Generate random text and all language pairs, verify successful translation
    - _Requirements: 1.1, 1.3_

  - [ ]* 5.3 Write property test for whitespace rejection
    - **Property 2: Whitespace Input Rejection**
    - **Validates: Requirements 1.5**
    - Generate whitespace-only strings, verify all are rejected
    - _Requirements: 1.5_

  - [ ]* 5.4 Write property test for error language consistency
    - **Property 3: Translation Error Language Consistency**
    - **Validates: Requirements 1.4**
    - Simulate API errors, verify error messages are in source language
    - _Requirements: 1.4_

  - [ ]* 5.5 Write property test for API response validation
    - **Property 4: API Response Validation**
    - **Validates: Requirements 7.3, 7.4**
    - Generate malformed API responses, verify they're caught and handled
    - _Requirements: 7.3, 7.4_

  - [ ]* 5.6 Write unit tests for translation edge cases
    - Test rate limit error handling
    - Test network failure with retry
    - Test timeout after 5 seconds
    - Test specific language pairs (Hindi→English, Tamil→Bengali)
    - _Requirements: 7.1, 7.2, 7.5_

- [ ] 6. Checkpoint - Ensure translation tests pass
  - Run pytest tests/property/test_translation_properties.py and tests/unit/test_translation_service.py
  - Verify all translation properties hold
  - Ask the user if questions arise

- [ ] 7. Implement Price Discovery Engine
  - [ ] 7.1 Create PriceDiscoveryEngine class with cache integration
    - Implement get_price() method
    - Create seed price database for common commodities (vegetables, fruits, grains)
    - Integrate with InMemoryCache for 6-hour caching
    - Add is_cache_fresh() and update_cache() methods
    - Implement commodity name normalization (lowercase, trim)
    - Add support for multi-language commodity queries using Gemini for translation
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 8.1, 8.2_

  - [ ]* 7.2 Write property test for price response completeness
    - **Property 5: Price Query Response Completeness**
    - **Validates: Requirements 3.1, 3.2**
    - Generate random commodity queries, verify all responses include min/max/avg/timestamp
    - _Requirements: 3.1, 3.2_

  - [ ]* 7.3 Write property test for unknown commodity error handling
    - **Property 7: Unknown Commodity Error Handling**
    - **Validates: Requirements 3.3**
    - Generate random invalid commodity names, verify appropriate error messages
    - _Requirements: 3.3_

  - [ ]* 7.4 Write unit tests for price discovery
    - Test specific commodities (tomato, apple, rice)
    - Test commodity in different languages
    - Test cache hit vs cache miss
    - Test stale cache data handling
    - _Requirements: 3.4, 8.1_

- [ ] 8. Implement Negotiation Assistant
  - [ ] 8.1 Create NegotiationAssistant class with price analysis
    - Implement analyze_price() method
    - Implement classify_price() logic (below_market, above_market, fair_low, fair_high)
    - Implement calculate_confidence() for confidence scoring
    - Implement generate_tips() with culturally appropriate phrases
    - Add fallback to basic mathematical comparison when Gemini API fails
    - Add data freshness warnings for stale price data (>24 hours)
    - _Requirements: 4.1, 4.2, 4.3, 4.5, 5.1, 5.3, 5.4, 5.5_

  - [ ]* 8.2 Write property test for price classification
    - **Property 11: Price Classification Correctness**
    - **Validates: Requirements 4.1, 4.2**
    - Generate random quoted prices and market data, verify correct classification
    - _Requirements: 4.1, 4.2_

  - [ ]* 8.3 Write property test for response language consistency
    - **Property 12: Negotiation Response Language Consistency**
    - **Validates: Requirements 4.3**
    - Generate requests in different languages, verify responses match
    - _Requirements: 4.3_

  - [ ]* 8.4 Write property test for fair price reasonableness
    - **Property 13: Fair Price Suggestion Reasonableness**
    - **Validates: Requirements 5.1**
    - Generate above-market prices, verify suggestions are between min and quoted price
    - _Requirements: 5.1_

  - [ ]* 8.5 Write property test for confidence score range
    - **Property 14: Confidence Score Range**
    - **Validates: Requirements 5.3**
    - Generate random negotiation requests, verify confidence scores are 0-100
    - _Requirements: 5.3_

  - [ ]* 8.6 Write property test for minimum tips count
    - **Property 15: Minimum Tips Count**
    - **Validates: Requirements 5.4**
    - Generate random queries, verify at least 2 tips are returned
    - _Requirements: 5.4_

  - [ ]* 8.7 Write unit tests for negotiation edge cases
    - Test Gemini API fallback to basic comparison
    - Test stale data warning (>24 hours)
    - Test specific price scenarios (way above market, way below market)
    - _Requirements: 4.5, 5.5_

- [ ] 9. Checkpoint - Ensure all backend tests pass
  - Run pytest tests/ -v to run all backend tests
  - Verify all properties and unit tests pass
  - Ask the user if questions arise

- [ ] 10. Implement FastAPI backend and API endpoints
  - [ ] 10.1 Create main FastAPI application with CORS
    - Set up FastAPI app in api/main.py
    - Add CORS middleware for cross-origin requests
    - Initialize services (TranslationService, PriceDiscoveryEngine, NegotiationAssistant)
    - Initialize cache singleton
    - _Requirements: 7.1, 9.2_

  - [ ] 10.2 Implement POST /api/translate endpoint
    - Accept TranslationRequest, return TranslationResponse
    - Call TranslationService.translate()
    - Handle validation errors (400), service errors (502), timeouts (504)
    - _Requirements: 1.1, 1.2, 1.4, 1.5_

  - [ ] 10.3 Implement GET /api/price endpoint
    - Accept commodity and language query parameters
    - Call PriceDiscoveryEngine.get_price()
    - Return PriceResponse with cache headers
    - Handle not found errors (404)
    - _Requirements: 3.1, 3.2, 3.3_

  - [ ] 10.4 Implement POST /api/negotiate endpoint
    - Accept NegotiationRequest, return NegotiationResponse
    - Call NegotiationAssistant.analyze_price()
    - Handle validation errors and service errors
    - _Requirements: 4.1, 4.2, 4.3, 5.1, 5.3, 5.4_

  - [ ] 10.5 Implement GET /api/health endpoint
    - Return health status, timestamp, service status
    - Check Gemini API connectivity
    - Check cache status
    - _Requirements: 7.2_

  - [ ]* 10.6 Write integration tests for API endpoints
    - Test each endpoint with valid requests
    - Test error responses (400, 404, 502, 504)
    - Test CORS headers
    - _Requirements: 1.1, 3.1, 4.1_

- [ ] 11. Implement frontend HTML structure
  - [ ] 11.1 Create index.html with mobile-first layout
    - Add semantic HTML5 structure
    - Create header with language selector
    - Create tab navigation (Translate | Prices | Negotiate)
    - Create Translation tab with source/target selectors, text input, voice button, output area
    - Create Price Discovery tab with commodity search, language selector, price display
    - Create Negotiation tab with commodity input, quoted price input, recommendation display
    - Add meta viewport tag for mobile responsiveness
    - _Requirements: 6.1, 10.1_

  - [ ] 11.2 Create styles.css with mobile-first responsive design
    - Use Flexbox/Grid for layout
    - Implement mobile breakpoint (<768px) as default
    - Ensure touch targets are minimum 44x44px
    - Use system fonts for fast loading
    - Add visual feedback styles (loading spinners, error messages, success states)
    - Add responsive styles for orientation changes
    - _Requirements: 6.1, 6.2, 6.4, 6.5_

- [ ] 12. Implement frontend JavaScript functionality
  - [ ] 12.1 Create app.js with core UI logic
    - Implement tab switching functionality
    - Implement translateText() function to call /api/translate
    - Implement searchPrice() function to call /api/price
    - Implement getNegotiationHelp() function to call /api/negotiate
    - Add loading state management (showLoading, hideLoading)
    - Add error handling and display (showError)
    - Add success message display
    - Use Fetch API for all HTTP requests
    - _Requirements: 1.1, 3.1, 4.1_

  - [ ] 12.2 Create voice.js with VoiceInputModule class
    - Implement VoiceInputModule constructor with language support
    - Implement startListening() with Web Speech API
    - Implement stopListening() method
    - Implement isSupported() to check browser compatibility
    - Add language mapping (hi-IN, en-IN, ta-IN, te-IN, bn-IN, mr-IN)
    - Add visual feedback (pulsing microphone icon, spinner, checkmark, error)
    - Populate translation input field on speech recognition complete
    - Display message when Web Speech API is unavailable
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

  - [ ]* 12.3 Write unit tests for frontend functions
    - Test translateText() with mock API
    - Test searchPrice() with mock API
    - Test getNegotiationHelp() with mock API
    - Test voice input with mock Web Speech API
    - Test error handling
    - _Requirements: 1.1, 2.1, 3.1, 4.1_

- [ ] 13. Checkpoint - Manual testing of frontend
  - Open index.html in browser
  - Test translation between different language pairs
  - Test voice input (if browser supports it)
  - Test price discovery for different commodities
  - Test negotiation assistant with various prices
  - Verify mobile responsiveness on different screen sizes
  - Ask the user if questions arise

- [ ] 14. Create deployment configuration
  - [ ] 14.1 Create vercel.json with routing rules
    - Configure Python runtime for /api/* routes
    - Configure static file serving for frontend
    - Add environment variable configuration
    - _Requirements: 9.1, 9.2, 9.3, 9.5_

  - [ ] 14.2 Create README.md with documentation
    - Add project overview and features
    - Add setup instructions (clone, install dependencies, set API key)
    - Add API documentation for all endpoints
    - Add deployment instructions for Vercel
    - Add usage examples
    - Add troubleshooting section
    - _Requirements: 10.3_

  - [ ]* 14.3 Verify deployment configuration
    - Check vercel.json syntax
    - Verify .env.example includes all required variables
    - Verify .gitignore excludes sensitive files
    - Test local deployment with vercel dev
    - _Requirements: 9.1, 9.3, 10.5_

- [ ] 15. Final integration and testing
  - [ ]* 15.1 Run full test suite
    - Run all property tests: pytest tests/property/ -v
    - Run all unit tests: pytest tests/unit/ -v
    - Run integration tests: pytest tests/integration/ -v
    - Verify all tests pass
    - _Requirements: All_

  - [ ] 15.2 End-to-end manual testing
    - Test complete translation workflow (text input → translate → display)
    - Test complete voice input workflow (speak → recognize → translate)
    - Test complete price discovery workflow (search → display prices)
    - Test complete negotiation workflow (input price → get recommendations)
    - Test error scenarios (invalid input, API failures, network issues)
    - Test on mobile device or mobile emulator
    - _Requirements: 1.1, 2.1, 3.1, 4.1, 6.1_

  - [ ] 15.3 Performance verification
    - Verify translation responses under 2 seconds
    - Verify cache is working (second query is faster)
    - Verify page loads in under 3 seconds on 3G
    - _Requirements: 1.2, 6.3, 8.2_

- [ ] 16. Final checkpoint - Deployment readiness
  - Ensure all tests pass
  - Verify README.md is complete
  - Verify .env.example is up to date
  - Verify code is modular and well-commented
  - Push to GitHub repository
  - Ask the user if ready to deploy to Vercel

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP development
- Each task references specific requirements for traceability
- Property tests validate universal correctness properties across many inputs
- Unit tests validate specific examples, edge cases, and error conditions
- Checkpoints ensure incremental validation and provide opportunities to address issues
- The implementation prioritizes P0 features (Translation, Voice Input, Price Lookup) with P1 features (Negotiation Assistant) integrated throughout
- All code should be modular, well-commented, and hackathon-friendly for multiple developers
