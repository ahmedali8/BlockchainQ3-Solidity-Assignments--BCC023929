const Web3 = require("web3");

console.log(Web3);

const rpcURL = "HTTP://127.0.0.1:7545";

let web3 = new Web3(rpcURL);

console.log("web3 instance = ", web3);

let address = "0x8598414586179075Ea68F68846dfc293943014e4";

web3.eth.getBalance(address, function (err, wei){
    console.log("Wei ", wei);
    let balance = web3.utils.fromWei(wei, "ether");
    console.log("Balance ", balance);
});