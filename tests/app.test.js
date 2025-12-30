const request = require('supertest');
const app = require('../src/app');

describe('Simple App Tests', () => {
    test('Welcome page should work', async () => {
        const response = await request(app).get('/');
        expect(response.status).toBe(200);
        expect(response.body.message).toBe('Welcome to Simple CI/CD Demo!');
    });

    test('Health check should work', async () => {
        const response = await request(app).get('/health');
        expect(response.status).toBe(200);
        expect(response.body.status).toBe('healthy');
    });

    test('API endpoint should work', async () => {
        const response = await request(app).get('/api/hello');
        expect(response.status).toBe(200);
        expect(response.body.success).toBe(true);
    });
});
