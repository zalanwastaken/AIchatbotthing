import requests
import socket
from dontexposeme.apis import GROQ_API_KEY # no public :|
from dontexposeme.chatbots import rishabsir # no public :|
from dontexposeme.chatbots import unamed # no public :|
from dontexposeme.chatbots import catgpt # no public :|
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
tcp = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
tcp.bind(("127.0.0.1", 5005))
tcp.listen(5)
while True:
    clientsocket, addr = tcp.accept()
    data = clientsocket.recv(4096)
    data = data.decode()
    print(data)
    predata = {
    "messages": [
            {
                "role": "system",
                "content": catgpt.description
            },
            {
                "role": "user",
                "content": data,
            },
        ],
        "model": catgpt.model,
    }
    clientsocket.send(get_groq_message(predata).encode())
    print("sent")
    clientsocket.close()