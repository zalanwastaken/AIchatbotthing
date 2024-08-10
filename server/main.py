import requests
from dontexposeme.apis import GROQ_API_KEY # no public :|
from dontexposeme.chatbots import rishabsir # no public :|
from dontexposeme.chatbots import unamed # no public :|
from dontexposeme.chatbots import catgpt # no public :|
predata = {
    "messages": [
        {
            "role": "system",
            "content": rishabsir.description
        },
        {
            "role": "user",
            "content": input("message: "),
        },
    ],
    "model": rishabsir.model,
}
def get_groq_message(data):
    try:
        response = requests.post(
            'https://api.groq.com/openai/v1/chat/completions',
            json=data,
            headers={
                'Authorization': f'Bearer {GROQ_API_KEY}',
                'Content-Type': 'application/json',
            }
        )
        response.raise_for_status()  # Raise an error for bad responses
        return response.json()['choices'][0]['message']['content']
    except requests.RequestException as error:
        print('Error:', error)
        raise
if __name__ == "__main__":
    try:
        message = get_groq_message(predata)
        print('Groq message:', message)
    except Exception as error:
        print('Error:', error)
