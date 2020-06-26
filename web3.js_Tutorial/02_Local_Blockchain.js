//accessed through node module
console.log(Web3);

const rpcURL = "HTTP://127.0.0.1:7545";

let web3 = new Web3(rpcURL);

let address = "0x743070062418733c3452D796A4523351bda0D4C5";

// web3.eth.getBalance(address, function (err, wei){
//     console.log("Wei ", wei);
//     let balance = web3.utils.fromWei(wei, "ether");
//     console.log("Balance ", balance);
// });

web3.eth.getBalance(address, (err, wei) => {
    if (err) {
        console.log("There is an error ", err);
    }
    else {
        console.log("Wei ", wei);
        let balance = web3.utils.fromWei(wei, "ether");
        console.log("Balance ", balance);
    }
});

