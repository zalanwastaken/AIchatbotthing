#! PYTHON 3.12
import requests
import socket
from dontexposeme.apis import GROQ_API_KEY  # no public :|
from dontexposeme.chatbots import rishabsir, unamed, catgpt  # no public :|
from helpers.generatetts import generateaudio
import os
predata = {
    "messages": [
        {
            "role": "system",
            "content": catgpt.description
        }
    ],
    "model": catgpt.model,
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
os.makedirs('audio', exist_ok=True)
tcp = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
tcp.bind(("127.0.0.1", 5005))
tcp.listen(5)
print("WORKING !")
response_content = None
while True:
    clientsocket, addr = tcp.accept()
    data = clientsocket.recv(4096).decode()
    newmsg = {
        "role": "user",
        "content": data
    }
    predata["messages"].append(newmsg)
    print("Received:", data)
    if data == "audio":
        if response_content != None:
            generateaudio(response_content, True)
        else:
            generateaudio("ERROR", True)
        audiofile = open("audio/tts.wav", "rb")
        try:
            clientsocket.sendall(audiofile.read())
            print("sent:", audiofile.read())
        except Exception as e:
            print(e)
        audiofile.close()
    elif data == "/kill":
        break
    else:
        response_content = get_groq_message(predata)
        newmsg = {
            "role": "assistant",
            "content": response_content
        }
        predata["messages"].append(newmsg)
        clientsocket.send(response_content.encode())
        print("Sent:", response_content)
    clientsocket.close()
print("STOPPED !")    
# * Made by Zalan(Zalander) aka zalanwastaken with Python🐍 and some 🎔
# ! ________  ________  ___       ________  ________   ___       __   ________  ________  _________  ________  ___  __    _______   ________      
# !|\_____  \|\   __  \|\  \     |\   __  \|\   ___  \|\  \     |\  \|\   __  \|\   ____\|\___   ___\\   __  \|\  \|\  \ |\  ___ \ |\   ___  \    
# ! \|___/  /\ \  \|\  \ \  \    \ \  \|\  \ \  \\ \  \ \  \    \ \  \ \  \|\  \ \  \___|\|___ \  \_\ \  \|\  \ \  \/  /|\ \   __/|\ \  \\ \  \   
# !     /  / /\ \   __  \ \  \    \ \   __  \ \  \\ \  \ \  \  __\ \  \ \   __  \ \_____  \   \ \  \ \ \   __  \ \   ___  \ \  \_|/_\ \  \\ \  \  
# !    /  /_/__\ \  \ \  \ \  \____\ \  \ \  \ \  \\ \  \ \  \|\__\_\  \ \  \ \  \|____|\  \   \ \  \ \ \  \ \  \ \  \\ \  \ \  \_|\ \ \  \\ \  \ 
# !   |\________\ \__\ \__\ \_______\ \__\ \__\ \__\\ \__\ \____________\ \__\ \__\____\_\  \   \ \__\ \ \__\ \__\ \__\\ \__\ \_______\ \__\\ \__\
# !    \|_______|\|__|\|__|\|_______|\|__|\|__|\|__| \|__|\|____________|\|__|\|__|\_________\   \|__|  \|__|\|__|\|__| \|__|\|_______|\|__| \|__|
# !                                                                                \|_________|                                                   
