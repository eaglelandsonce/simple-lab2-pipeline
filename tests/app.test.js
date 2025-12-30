const request = require('supertest');
const app = require('../src/app');

describe('Simple App Tests', () => {
    test('Welcome page should work', async () => {
        const response = await request(app).get('/');
        expect(response.status).toBe(200);
        expect(response.body.message).toBe('Welcome to Simple CI/CD Demo!');
    });

    test('API endpoint should work', async () => {
        const response = await request(app).get('/api/hello');
        expect(response.status).toBe(200);
        expect(response.body.success).toBe(true);
    });
});

describe('Health Endpoint Tests', () => {
    test('/health should return 200 and include status, env, and version', async () => {
        const response = await request(app).get('/health');
        
        expect(response.status).toBe(200);
        expect(response.body).toHaveProperty('status');
        expect(response.body).toHaveProperty('env');
        expect(response.body).toHaveProperty('version');
        expect(response.body.status).toBe('ok');
    });
});

describe('Performance Endpoint Tests', () => {
    test('/performance should return 200 and include uptimeSeconds and memory', async () => {
        const response = await request(app).get('/performance');
        
        expect(response.status).toBe(200);
        expect(response.body).toHaveProperty('uptimeSeconds');
        expect(response.body).toHaveProperty('memory');
        expect(typeof response.body.uptimeSeconds).toBe('number');
        expect(response.body.uptimeSeconds).toBeGreaterThanOrEqual(0);
        expect(response.body.memory).toHaveProperty('rss');
        expect(response.body.memory).toHaveProperty('heapTotal');
        expect(response.body.memory).toHaveProperty('heapUsed');
    });
});

describe('Build Info Endpoint Tests', () => {
    test('/build-info should return 200 and either real build-info or {available:false}', async () => {
        const response = await request(app).get('/build-info');
        
        expect(response.status).toBe(200);
        
        // Accept either real build info or not available response
        if (response.body.available === false) {
            expect(response.body).toHaveProperty('message');
            expect(response.body.message).toBe('build-info not found');
        } else {
            // If build-info is available, it should be an object
            expect(typeof response.body).toBe('object');
        }
    });
});

describe('404 Handling Tests', () => {
    test('Unknown route should return 404 with JSON error', async () => {
        const response = await request(app).get('/unknown-route');
        
        expect(response.status).toBe(404);
        expect(response.body).toEqual({ error: 'Not Found' });
    });

    test('Another unknown route should return 404 with JSON error', async () => {
        const response = await request(app).post('/invalid');
        
        expect(response.status).toBe(404);
        expect(response.body).toEqual({ error: 'Not Found' });
    });
});
