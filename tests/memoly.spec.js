import { expect, test } from "playwright/test";

test('POST /note returns 200', async({request}) => {
    const response = await request.post("http://localhost:4000/notes", {
        data: {
            note: {
                raw_content: "Lorem ipsum",
                source: "https://www.example.com"
            }
        },
        headers: {
            "Content-Type": "application/json"
        }
    });
    
    expect(response.status()).toBe(201);
    
    const responseBody = await response.json();
    const expectedResponseBody = {
        id: expect.any(Number),
        raw_content: "Lorem ipsum",
        source: "https://www.example.com",
        created_at: expect.any(String),
        updated_at: expect.any(String),
        reminders: []
    }

    expect(responseBody).toMatchObject(expectedResponseBody);
});