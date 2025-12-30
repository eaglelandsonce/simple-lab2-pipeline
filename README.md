# simple-cicd-pipeline

A tiny Express app + Jest tests + a GitHub Actions workflow.

## Run locally
```bash
npm install
npm test
npm run build
npm start
```

## Endpoints
- GET /        -> Welcome message + version
- GET /health  -> status + timestamp
- GET /api/hello -> greeting + success flag
