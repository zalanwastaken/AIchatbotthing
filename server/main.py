import requests
import socket
#from RealtimeTTS import TextToAudioStream, GTTSEngine
from dontexposeme.apis import GROQ_API_KEY  # no public :|
from dontexposeme.chatbots import rishabsir  # no public :|
from dontexposeme.chatbots import unamed  # no public :|
from dontexposeme.chatbots import catgpt  # no public :|
#audioengine = GTTSEngine()
#audiostream = TextToAudioStream(engine=audioengine)
predata = {
    "messages": [
        {
            "role": "system",
            "content": unamed.description
        }
    ],
    "model": unamed.model,
    "max_tokens": 2048
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
        response_json = response.json()
        # Adjust based on actual response structure
        return response_json['choices'][0]['message']['content']
    except requests.RequestException as error:
        print('Error:', error)
        raise
tcp = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
tcp.bind(("127.0.0.1", 5005))
tcp.listen(5)
while True:
    clientsocket, addr = tcp.accept()
    data = clientsocket.recv(4096).decode()
    newmsg = {
        "role": "user",
        "content": data
    }
    predata["messages"].append(newmsg)
    print("Received:", data)
    try:
        response_content = get_groq_message(predata)
        #audiostream.feed(response_content)
        #clientsocket.send(response_content.encode())
        #audiostream.play(output_wavfile="output.wav", muted=True)
        #audiofile = open("output.wav", "rb")
        clientsocket.sendall(response_content.encode())
        #audiofile.close()
        print("Sent:", response_content)
    except Exception as e:
        print("Error in message handling:", e)
    clientsocket.close()
