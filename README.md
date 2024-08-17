# THIS PROJECT IS CURRENTLY IN TESTING AND SOULD BE CONSIDERED UNSTABLE
## How to setup:
### Install dependencies
    sudo apt update -y
    sudo add-apt-repository ppa:bartbes/love-stable
    sudo apt install love -y
    sudo pip install piper requests socket
### Make the api file
    mkdir dontexposeme
    touch dontexposeme/apis.py
    echo "GROQ_API_KEY = <replace with your groq api key !>" > dontexposeme/apis.py
### Make the chabots file
    touch dontexposeme/chatbots.py
    cat setup/chatbots.py > dontexposeme/chatbots.py

## How to run:
### Run the server
    cd server
    python3 main.py
### Run the client
    cd client
    love .
