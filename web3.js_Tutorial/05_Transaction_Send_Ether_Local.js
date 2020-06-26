var Tx = require('ethereumjs-tx').Transaction;

const Web3 = require('web3');
let rpcURL = "HTTP://127.0.0.1:7545";
const web3 = new Web3(rpcURL);

const account1 = "0x98681A88da68453e279452CF749fFA7CFF3FD96F";
const account2 = "0x87Bf2a054cc2ddb29ad86F2eD5a8eF4B59d753BA";

const privateKey1 = "cf34724a2894a602d0f744d555add4593bbbc9e480d3a9c30055cd48e9ad6f86";
const privateKey2 = "c91238cc1ed53259cc7f57d6fec6f129604a4f697041a285c70aa2cb67b66678";

const privateKey1Buffer = Buffer.from(privateKey1, 'hex');
const privateKey2Buffer = Buffer.from(privateKey2, 'hex');

console.log("Buufer 1 = ", privateKey1Buffer);
console.log("Buufer 2 = ", privateKey2Buffer);

web3.eth.getTransactionCount(account1, (err, txCount) => {
    //Build a transaction object
    let txObject = {
        nonce: web3.utils.toHex(txCount),
        to: account2,
        value: web3.utils.toHex(web3.utils.toWei('2', 'ether')),
        gasLimit: web3.utils.toHex(21000),
        gasPrice: web3.utils.toHex(web3.utils.toWei('10','gwei'))
    }

    //Sign the transaction
    const tx = new Tx(txObject);
    tx.sign(privateKey1Buffer);

    const serializedTx = tx.serialize();
    const raw = '0x' + serializedTx.toString('hex');

    console.log('Tx = ', tx);
    console.log('serializedTx = ', serializedTx);
    console.log('raw = ', raw);

    //Broadcast to network
    web3.eth.sendSignedTransaction(raw, (err, txHash) => {
        console.log('txHash = ', txHash)
    });
});