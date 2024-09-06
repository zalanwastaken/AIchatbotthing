const {groqapikey, SSKEY} = require("./dontexposeme/dontexposeme")
const users = require("./dontexposeme/users")
const Groq = require("groq-sdk")
const crypto = require('crypto')
const groq = new Groq({apiKey: groqapikey})
const tcp = require("net")
//*vars
let loggedinusers = {}
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
                    }).trim())
                }
                if(jsondata.head.reqtype == "HELO"){
                    if(await handlelogin(jsondata.data.user, jsondata.data.pass) == true){
                        if(typeof loggedinusers[jsondata.data.user] === "undefined"){
                            var userkey = generateRandomString(16)
                            var sendkey = ""
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
                        }
                        else{
                            sock.write(JSON.stringify({
                                head:{
                                    type:"data/error"
                                },
                                data:{
                                    message:"User already has a active session"
                                }
                            }).trim())
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
                        }).trim())
                    }
                }
                if(jsondata.head.reqtype == "BYE"){
                    if(typeof loggedinusers[jsondata.data.user] !== "undefined"){
                        if(loggedinusers[jsondata.data.user] == jsondata.data.key){
                            delete loggedinusers[jsondata.data.user]
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
                            console.log("key err")
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
                        console.log("unknown user err")
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
            console.log("Logged in users:", loggedinusers);
        })
        sock.on("end", ()=>{
            console.log("client diconnected")
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
//* Made by Zalan(Zalander) aka zalanwastaken with NodeJS and some 🎔
//! ________  ________  ___       ________  ________   ___       __   ________  ________  _________  ________  ___  __    _______   ________      
//!|\_____  \|\   __  \|\  \     |\   __  \|\   ___  \|\  \     |\  \|\   __  \|\   ____\|\___   ___\\   __  \|\  \|\  \ |\  ___ \ |\   ___  \    
//! \|___/  /\ \  \|\  \ \  \    \ \  \|\  \ \  \\ \  \ \  \    \ \  \ \  \|\  \ \  \___|\|___ \  \_\ \  \|\  \ \  \/  /|\ \   __/|\ \  \\ \  \   
//!     /  / /\ \   __  \ \  \    \ \   __  \ \  \\ \  \ \  \  __\ \  \ \   __  \ \_____  \   \ \  \ \ \   __  \ \   ___  \ \  \_|/_\ \  \\ \  \  
//!    /  /_/__\ \  \ \  \ \  \____\ \  \ \  \ \  \\ \  \ \  \|\__\_\  \ \  \ \  \|____|\  \   \ \  \ \ \  \ \  \ \  \\ \  \ \  \_|\ \ \  \\ \  \ 
//!   |\________\ \__\ \__\ \_______\ \__\ \__\ \__\\ \__\ \____________\ \__\ \__\____\_\  \   \ \__\ \ \__\ \__\ \__\\ \__\ \_______\ \__\\ \__\
//!    \|_______|\|__|\|__|\|_______|\|__|\|__|\|__| \|__|\|____________|\|__|\|__|\_________\   \|__|  \|__|\|__|\|__| \|__|\|_______|\|__| \|__|
//!                                                                                \|_________|                                                   
