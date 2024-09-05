const {groqapikey, SSKEY} = require("./dontexposeme/dontexposeme")
const users = require("./dontexposeme/users")
const Groq = require("groq-sdk")
const crypto = require('crypto')
const groq = new Groq({apiKey: groqapikey})
const tcp = require("net")
//*vars
var loggedinusers = {}
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
                        if(typeof loggedinusers[jsondata.data.user] === "undefined"){
                            let userkey = generateRandomString(16)
                            let sendkey = ""
                            if(users[jsondata.data.user].uid < 10){
                                sendkey = SSKEY
                            }
                            sock.write(JSON.stringify({
                                head : {
                                    type:"data/data"
                                },
                                data : {
                                    key:userkey,
                                    sskey:sendkey
                                }
                            }).trim())
                            loggedinusers[jsondata.data.user] = userkey
                            console.log(loggedinusers[jsondata.data.user])
                        }
                        else{
                            sock.write(JSON.stringify({
                                head:{
                                    type:"data/error"
                                },
                                data:{
                                    message:"User already has a active session"
                                }
                            }))
                        }
                    }
                    else{
                        sock.write(JSON.stringify({
                            head : {
                                type:"data/error"
                            },
                            data :{
                                message:"AUTH FAILED !"
                            }
                        }))
                    }
                }
                if(jsondata.head.reqtype == "BYE"){
                    if(typeof loggedinusers[jsondata.data.user] !== "undefined"){
                        if(loggedinusers[jsondata.data.user] == jsondata.data.key){
                            loggedinusers[jsondata.data.user] = undefined
                            sock.write(JSON.stringify({
                                head:{
                                    type:"data/data"
                                },
                                data:{
                                    contents:"success"
                                }
                            }).trim())
                        }
                        else{
                            sock.write(JSON.stringify({
                                head:{
                                    type:"data/error"
                                },
                                data:{
                                    contents:"error logging out"
                                }
                            }).trim())
                        }
                    }
                    else{
                        sock.write(JSON.stringify({
                            head:{
                                type:"data/error"
                            },
                            data:{
                                contents:"error logging out"
                            }
                        }).trim())
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
