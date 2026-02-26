# Requirements Document: Multilingual Mandi

## Introduction

Multilingual Mandi is a web platform designed to help Indian local market vendors break language barriers, discover fair market prices, and negotiate effectively. The system enables vendors to communicate across 6+ Indian languages, access real-time market price information, and receive AI-powered negotiation assistance. This hackathon project prioritizes rapid deployment, mobile-first design, and zero-cost infrastructure using free-tier services.

## Glossary

- **Translation_System**: The component responsible for converting text between supported Indian languages
- **Voice_Input_Module**: The component that captures and processes spoken language using browser Web Speech API
- **Price_Discovery_Engine**: The component that retrieves and displays market price information for commodities
- **Negotiation_Assistant**: The component that analyzes prices and provides negotiation recommendations
- **Gemini_API**: Google's AI service used for translation and intelligent price analysis
- **Supported_Language**: One of Hindi, English, Tamil, Telugu, Bengali, or Marathi
- **Commodity**: A tradeable item such as vegetables, fruits, or grains
- **Market_Price**: The current price range (minimum, maximum, average) for a commodity in ₹/kg
- **Quoted_Price**: The price offered by a seller during negotiation
- **Fair_Price**: A price within reasonable bounds of the market average
- **Confidence_Score**: A numerical indicator (0-100) of how reliable a suggestion is

## Requirements

### Requirement 1: Multi-Language Translation

**User Story:** As a market vendor, I want to translate text between Indian languages, so that I can communicate with customers who speak different languages.

#### Acceptance Criteria

1. WHEN a user provides text in any Supported_Language, THE Translation_System SHALL translate it to any other Supported_Language
2. WHEN a translation request is received, THE Translation_System SHALL return the translated text within 2 seconds
3. THE Translation_System SHALL support all language pairs among Hindi, English, Tamil, Telugu, Bengali, and Marathi
4. WHEN the Gemini_API returns an error, THE Translation_System SHALL return a descriptive error message in the source language
5. WHEN a user provides empty or whitespace-only text, THE Translation_System SHALL reject the request and return an error

### Requirement 2: Voice Input Support

**User Story:** As a market vendor, I want to speak in my language instead of typing, so that I can quickly communicate without using a keyboard.

#### Acceptance Criteria

1. WHEN a user activates voice input, THE Voice_Input_Module SHALL capture spoken language using the browser Web Speech API
2. WHEN speech is captured, THE Voice_Input_Module SHALL convert it to text in the detected Supported_Language
3. WHEN voice input is active, THE Voice_Input_Module SHALL provide visual feedback indicating recording status
4. IF the browser does not support Web Speech API, THEN THE Voice_Input_Module SHALL display a message indicating voice input is unavailable
5. WHEN voice input completes, THE Voice_Input_Module SHALL populate the translation input field with the captured text

### Requirement 3: Market Price Discovery

**User Story:** As a market vendor, I want to look up current market prices for commodities, so that I can make informed pricing decisions.

#### Acceptance Criteria

1. WHEN a user queries a Commodity in any Supported_Language, THE Price_Discovery_Engine SHALL return the Market_Price range (minimum, maximum, average) in ₹/kg
2. WHEN displaying Market_Price information, THE Price_Discovery_Engine SHALL include a timestamp indicating when the data was last updated
3. WHEN a Commodity is not found, THE Price_Discovery_Engine SHALL return a message indicating no price data is available
4. THE Price_Discovery_Engine SHALL support queries for vegetables, fruits, and grains
5. WHEN multiple users query the same Commodity, THE Price_Discovery_Engine SHALL return consistent price data within the same update period

### Requirement 4: AI-Powered Price Analysis

**User Story:** As a market vendor, I want the system to analyze prices using AI, so that I can understand if a price is fair based on current market conditions.

#### Acceptance Criteria

1. WHEN a user provides a Commodity name and Quoted_Price, THE Negotiation_Assistant SHALL compare it against the current Market_Price
2. WHEN the Quoted_Price is analyzed, THE Negotiation_Assistant SHALL classify it as above, below, or within the fair market range
3. WHEN providing analysis, THE Negotiation_Assistant SHALL return results in the user's selected Supported_Language
4. THE Negotiation_Assistant SHALL use the Gemini_API to generate contextual price analysis
5. WHEN the Gemini_API is unavailable, THE Negotiation_Assistant SHALL fall back to basic mathematical comparison

### Requirement 5: Negotiation Recommendations

**User Story:** As a market vendor, I want to receive negotiation tips and fair price suggestions, so that I can negotiate effectively with suppliers or customers.

#### Acceptance Criteria

1. WHEN a Quoted_Price is above the market average, THE Negotiation_Assistant SHALL suggest a Fair_Price closer to the average
2. WHEN providing negotiation tips, THE Negotiation_Assistant SHALL include culturally appropriate phrases in the user's Supported_Language
3. WHEN generating recommendations, THE Negotiation_Assistant SHALL include a Confidence_Score indicating reliability
4. THE Negotiation_Assistant SHALL provide at least 2 actionable negotiation tips per query
5. WHEN the Market_Price data is stale (>24 hours old), THE Negotiation_Assistant SHALL include a warning about data freshness

### Requirement 6: Mobile-First User Interface

**User Story:** As a market vendor using a mobile phone, I want a responsive interface that works well on small screens, so that I can use the platform on my device.

#### Acceptance Criteria

1. WHEN the platform is accessed on a mobile device, THE User_Interface SHALL display content optimized for screen widths below 768px
2. WHEN touch interactions are used, THE User_Interface SHALL provide appropriately sized touch targets (minimum 44x44px)
3. THE User_Interface SHALL load and become interactive within 3 seconds on 3G mobile connections
4. WHEN the device orientation changes, THE User_Interface SHALL adapt the layout appropriately
5. THE User_Interface SHALL use system fonts and minimal external resources to ensure fast loading

### Requirement 7: API Integration and Error Handling

**User Story:** As a system administrator, I want robust API integration with proper error handling, so that the platform remains reliable even when external services fail.

#### Acceptance Criteria

1. WHEN the Gemini_API rate limit is exceeded, THE Translation_System SHALL return a user-friendly error message
2. WHEN network connectivity is lost, THE Translation_System SHALL detect the failure and inform the user
3. THE Translation_System SHALL validate API responses before processing them
4. WHEN the Gemini_API returns malformed data, THE Translation_System SHALL log the error and return a safe fallback response
5. THE Translation_System SHALL implement request timeouts of 5 seconds to prevent hanging requests

### Requirement 8: Data Persistence and Caching

**User Story:** As a system operator, I want price data to be cached appropriately, so that the platform can serve requests efficiently and reduce API costs.

#### Acceptance Criteria

1. WHEN Market_Price data is fetched, THE Price_Discovery_Engine SHALL cache it for 6 hours
2. WHEN cached data exists and is fresh, THE Price_Discovery_Engine SHALL serve it without making external API calls
3. THE Price_Discovery_Engine SHALL store cache timestamps to determine data freshness
4. WHEN the cache is full, THE Price_Discovery_Engine SHALL evict the oldest entries first
5. THE Price_Discovery_Engine SHALL persist cache data to survive server restarts

### Requirement 9: Deployment and Configuration

**User Story:** As a developer, I want simple one-click deployment to Vercel, so that the platform can be deployed quickly during the hackathon.

#### Acceptance Criteria

1. THE Deployment_Configuration SHALL include a vercel.json file with proper routing rules
2. WHEN deployed to Vercel, THE Backend_API SHALL serve requests from the /api/* path
3. THE Deployment_Configuration SHALL include environment variable placeholders for the Gemini_API key
4. WHEN the repository is connected to Vercel, THE Platform SHALL deploy automatically on git push
5. THE Deployment_Configuration SHALL serve the frontend as static files from the root path

### Requirement 10: Code Modularity and Documentation

**User Story:** As a hackathon participant, I want well-organized modular code, so that other developers can understand and extend the platform.

#### Acceptance Criteria

1. THE Codebase SHALL separate concerns into distinct modules (translation, pricing, negotiation, UI)
2. WHEN a module is created, THE Codebase SHALL include inline comments explaining key functions
3. THE Codebase SHALL include a README.md with setup instructions and API documentation
4. WHEN functions are defined, THE Codebase SHALL use descriptive names that indicate their purpose
5. THE Codebase SHALL avoid external build tools and use vanilla JavaScript for the frontend
