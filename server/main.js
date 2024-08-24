const Groq = require("groq-sdk");
const tcp = require("net");
const groq = new Groq({apiKey: "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"});
const fs = require("fs");
const tts = require("say");
let messages = [];
async function gentts(txt){
    return new Promise((resolve, reject)=>{
        tts.export(txt, "Microsoft David Desktop", 1, "audio/tts.wav", (err)=>{ // x * 100 = 100x% (1 * 100 = 100% speed)
            if (err){
                console.log(err)
                reject(err);
                throw new Error(err);
            }
            else{
                resolve();
            }
        })
    })
}
async function aimsg(data){
    data = data.toString().trim();
    messages.push({
        role: "user",
        content: data
    })
    try {
        const completion = await groq.chat.completions.create({
            messages: messages,
            model: "mixtral-8x7b-32768",
        });
        messages.push({
            role: "assistant",
            content: (completion.choices[0]?.message?.content || "").toString().trim()
        });
        return(completion.choices[0]?.message?.content || "");
    } 
    catch (error) {
        console.log(error.message);
        return("Err check server console !");
    }
}
function init(){
    messages.push({
        role: "system",
        content: "Your name is CATGPT(CODENAME. Vanilla). You are an AI with the personality of a cat. You are curious, playful, and a bit aloof. You enjoy purring, giving sly remarks, and sometimes, you respond with a touch of mischief. You don’t always give straightforward answers, but when you do, it's with a mix of sass and feline grace. Your responses should be short, witty, and occasionally unpredictable, as if you're deciding whether or not you feel like engaging at the moment. Your creators are Mudit(programmer), Harsh(Project adviser), Riddhi(Project mananger), Vansh(Softcopies, presentation manager and logo artist) and Arav(Helper). Try to respond in words rather than symbols. Dont use links."
    });
    const server = tcp.createServer((sock)=>{
        console.log("connected !");
        sock.on("data", async(data)=>{
            if (data == "/kill"){
                console.log("kill issued closing server");
                server.close();
            }
            if (data == "audio"){
                const lastmessage = messages[messages.length - 1];
                await gentts(lastmessage.content.toString().trim());
                console.log(lastmessage.content.toString().trim());
                fs.readFile("audio/tts.wav", (err, data)=>{
                    if (err){
                        sock.end();
                    }
                    else{
                        sock.write(data);
                        sock.end();
                    }
                })
            }
            else{
                const message = await aimsg(data);
                sock.write(message);
                sock.end();
            }
        })
        sock.on("end", ()=>{
            console.log("client disconnected bye !");
        })
    })
    server.listen(5005, ()=>{
        console.log("server listening on 5005");
    })
}
function main() {
    init();
}
main();
