const express = require('express');
const fs = require('fs');
const path = require('path');

// just a comment plus 2

const app = express();
const PORT = process.env.PORT || 3000;

// Determine environment
const env = process.env.NODE_ENV || 'development';

// Read version from package.json
const packageJson = require('../package.json');
const version = packageJson.version;

// Try to read build-info.json
let buildInfo = null;
const buildInfoPath = path.join(__dirname, '../dist/build-info.json');
try {
  const buildInfoData = fs.readFileSync(buildInfoPath, 'utf8');
  buildInfo = JSON.parse(buildInfoData);
} catch (error) {
  // build-info.json not available
  buildInfo = null;
}

// Store start time for uptime calculation
const startTime = Date.now();

// Middleware
app.use(express.json());

// Simple welcome page
app.get('/', (req, res) => {
    res.json({
        message: 'Welcome to Simple CI/CD Demo!',
        version: version
    });
});

// GET /health endpoint - returns status, env, and version
app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        env: env,
        version: version
    });
});

// GET /build-info endpoint - returns build info if available
app.get('/build-info', (req, res) => {
    if (buildInfo) {
        res.json(buildInfo);
    } else {
        res.json({
            available: false,
            message: 'build-info not found'
        });
    }
});

// GET /performance endpoint - returns runtime metrics
app.get('/performance', (req, res) => {
    const uptimeSeconds = (Date.now() - startTime) / 1000;
    const memory = process.memoryUsage();
    
    res.json({
        uptimeSeconds: uptimeSeconds,
        memory: memory
    });
});

// Simple API endpoint
app.get('/api/hello', (req, res) => {
    res.json({
        greeting: 'Hello from CI/CD Pipeline!',
        success: true
    });
});

// 404 handler for unknown routes
app.use((req, res) => {
    res.status(404).json({
        error: 'Not Found'
    });
});

// Start server (only if not in test mode)
if (process.env.NODE_ENV !== 'test') {
    app.listen(PORT, () => {
        console.log(`Server running on port ${PORT} in ${env} mode`);
    });
}

module.exports = app;
