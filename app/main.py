import requests
import json
import sseclient
from config import Config

def performReqWithStreaming():
    reqUrl = 'https://api.openai.com/v1/chat/completions'
    reqHeaders = {
        'Accept': 'application/json',
        'Authorization': f"Bearer {Config.OPENAI_API_KEY}"
    }
    reqBody = {
        'model': 'gpt-3.5-turbo',
        'messages': [
            {
                "role": "system",
                "content": "You are a helpful assistant."
            },
            {
                "role": "user",
                "content": "Hello, how do you like Python?"
            }
            ], 
        # 'max_tokens': 100,
        # 'temperature': 0,
        'stream': True,
    }

    request = requests.post(reqUrl, stream=True, headers=reqHeaders, json=reqBody)
    if request.status_code in range(400, 500):
        print(f"Error {request.status_code}: {request.text}")
    client = sseclient.SSEClient(request)
    for event in client.events():
        if event.data != '[DONE]':
            print(json.loads(event.data)['choices'][0]['text'], end="", flush=True)

if __name__ == "__main__":
    performReqWithStreaming()
