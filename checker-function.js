const fs = require('fs')
const http = require('http')
const path = require('path')

async function http_request_function(url) {
    try {
        const response = await new Promise ((resolve, reject)=> {
            http.get(url, (res)=> {
                let data =''

                res.on ('data', (chunk)=>{
                    data += chunk;
                })
                res.on('end', ()=>{
                    const responseObject =data
                    resolve (responseObject)
                })
                res.on('error', (error)=>{
                    reject(new Error (`Request Error: ${error.message}`))
                })
            })
        })
        return response;
    } catch(error){
        console.log("Error in fetching domain names: ",error.message)
        throw error;
    }
}

async function fetch_function(){
    const url = "http://platf-publi-18fsqbv7zkatz-264338888.us-east-1.elb.amazonaws.com/client/getclienturls"
    const domain_list = JSON.parse(await http_request_function(url))

    
    // console.log(typeof(domain_list))
    const formatted_list = new Set()
    for (const str of domain_list){
        const i = str.toString().toLowerCase().replace("www.", "").trim();
        formatted_list.add(i)
        // console.log(str)
    }


    return formatted_list
    // console.log(formatted_list.size)
}

const checker_function = async (req, res) => {
    try {
        const formatted_list = await fetch_function()

        // Created the folder for testing purpose

    //     for (const domain of formatted_list){
    //         fs.mkdir(path.join(__dirname, "certs" ,domain), 
    //             (err)=> {
    //                 if (err){
    //                     console.log(err.message)
    //                 }
    //                 console.log("Directory created successfully")
    //             })
    //     }

        const certs_address = '/var/www/certificates/live'
        // const certs_address = path.join(__dirname, "certs")
        const certs = fs.readdirSync(certs_address)
        // console.log(typeof(certs))

        // const confs_address ='/etc/nginx/sites'
        // const confs = fs.readdirSync(confs_address)

        const map1 = new Map()

        for (const cert of certs){

            if (map1[cert] === undefined) map1[cert] = 1;
            else map1[cert]++;
        }

        // console.log(map1)
        const list = []
        for (const i of formatted_list){
            if (map1[i] === undefined){ 
                list.push(i)
                console.log(i)
            }
        }
        console.log(list)

        res.send(`List of the domains with no SSL certificate is ${list}`)
    } 
    catch (error){
        console.log("Error in getting the difference:: ", error.message)
    }
}

// checker_function()

module.exports = checker_function 