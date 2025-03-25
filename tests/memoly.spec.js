import { expect, test } from "playwright/test";

test('POST /note returns 200', async({request}) => {
    const response = await request.post('http://localhost:4000/notes', {
        data: {
            note: {
                raw_content: "Lorem ipsom",
                source: "https://www.example.com"
            }
        },
        headers: {
            'Content-Type': 'application/json'
        }
    });
    
    expect(response.status()).toBe(201);
});