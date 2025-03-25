/*
import { test, expect } from '@playwright/test';

// Basic test to verify the API is running and returns expected response
test('API health check', async ({ request }) => {
  // Assuming Rails API has a health check endpoint
  const response = await request.get('/health');
  
  // Expect the request to be successful
  expect(response.status()).toBe(200);
  
  // Verify response format
  const body = await response.json();
  expect(body).toHaveProperty('status', 'ok');
});

// Test to verify the API returns proper error for non-existent endpoints
test('API returns 404 for non-existent routes', async ({ request }) => {
  const response = await request.get('/non-existent-endpoint');
  expect(response.status()).toBe(404);
});

// Test to verify basic CORS headers
test('API includes proper CORS headers', async ({ request }) => {
  const response = await request.get('/health', {
    headers: {
      'Origin': 'http://localhost:8080'
    }
  });
  
  // Check for CORS headers
  const headers = response.headers();
  expect(headers).toHaveProperty('access-control-allow-origin');
});

// Optional: Test authentication if your API has auth endpoints
test('API authentication flow', async ({ request }) => {
  // Example of testing an auth flow - adjust based on your actual API implementation
  const loginResponse = await request.post('/auth/login', {
    data: {
      email: 'test@example.com',
      password: 'password123'
    }
  });
  
  // You might comment this out initially until you implement authentication
  expect(loginResponse.status()).toBe(200);
  const body = await loginResponse.json();
  expect(body).toHaveProperty('token');
});

*/