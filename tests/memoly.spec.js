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
});