---
inclusion: always
---

# Hackathon Development Guidelines

## Philosophy
**Minimum code, maximum impact. Free tools only. Ship fast, ship working.**

## Code Standards

### Modularity
- Each function does ONE thing
- Maximum 30 lines per function
- Clear separation of concerns

### Self-Documenting Code
- Every file starts with a docstring explaining its purpose
- Complex logic gets inline comments with "WHY", not "WHAT"
- Export a `# TODO:` section at file end for incomplete features

### Error Handling
- Graceful degradation - never crash on API failures
- User-friendly error messages
- Log errors for debugging

### AI Handoff Ready
Leave breadcrumbs for other developers:
```python
# NEXT_DEVELOPER: This function needs caching. See issue #3.
```

## Library Philosophy
- **Use libraries** for: Auth, Translation APIs, UI components
- **Build custom** for: Core business logic, domain-specific features
- **Prefer**: Single-purpose packages over monolithic frameworks

## Testing Approach
- Test P0 features thoroughly
- P1 features can have minimal tests
- Focus on integration tests over unit tests for speed

## Deployment
- Must work on Vercel free tier
- Environment variables for all secrets
- One-click deployment from GitHub

## Time Management
- P0 features: 100% completion required
- P1 features: Only if time permits
- P2 features: Document for future work

## Success Criteria
1. Works end-to-end
2. Handles 3+ Indian languages
3. Mobile-friendly
4. Deploys in 1 click
5. Code is resumable by another developer in <10 minutes
