//accessed through node module
console.log(Web3);

const rpcURL = "https://ropsten.infura.io/v3/e9595b79cb2d4128b8e2457fd0932edd";

let web3 = new Web3(rpcURL);

let address = "0x09E78Ec232C168ec6ef420675F813C4719A811f8";

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

