const {groqapikey, SSKEY} = require("./dontexposeme/dontexposeme")
const users = require("./dontexposeme/users")
const Groq = require("groq-sdk")
const crypto = require('crypto');
const groq = new Groq({apiKey: groqapikey})
const tcp = require("net");
//* funcs
function generateRandomString(length) {
    return crypto.randomBytes(length).toString('hex').slice(0, length);
}
async function getaimsg(txt){}
async function handlelogin(username, pass){
    const udata = users[username]
    if (typeof udata !== "undefined"){
        if (udata.uid < 10){
            console.warn("Accessing admin user !")
        }
        if (udata.pass == pass){
            return(true)
        }
        else{
            return(false)
        }
    }
    else{
        return(false)
    }
}
//* init
async function init(){
    const server = tcp.createServer((sock)=>{
        sock.on("data", async(data)=>{
            jsondata = JSON.parse(data.toString().trim())
            if(jsondata.head.type == "data/data"){
                if(jsondata.head.reqtype == "ping"){
                    sock.write(JSON.stringify({
                        head:{
                            type : "data/data"
                        },
                        data : {
                            ping : "pong"
                        }
                    }))
                }
                if(jsondata.head.reqtype == "HELO"){
                    if(await handlelogin(jsondata.data.user, jsondata.data.pass) == true){
                        if(users[jsondata.data.user].uid < 10){
                            sock.write(JSON.stringify({
                                head : {
                                    type : "data/data"
                                },
                                data : {
                                    key :generateRandomString(16),
                                    sskey : SSKEY
                                }
                            }).trim())
                        }
                        else{
                            sock.write(JSON.stringify({
                                head : {
                                    type : "data/data"
                                },
                                data : {
                                    key : generateRandomString(16)
                                }
                            }))
                        }
                    }
                    else{
                        sock.write(JSON.stringify({
                            head : {
                                type : "data/data"
                            },
                            data :{
                                key : "AUTH FAILED !"
                            }
                        }))
                    }
                }
            }
            sock.end()
        })
    })
    server.listen(5005, ()=>{
        console.log("TCP server running !")
    })
}
//* main
async function main(){
    init(()=>{
        console.log("TCP server ended !")
    })
}
main()
