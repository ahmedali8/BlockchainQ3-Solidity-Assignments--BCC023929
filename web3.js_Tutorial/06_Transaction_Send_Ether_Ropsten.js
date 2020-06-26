var Tx = require('ethereumjs-tx').Transaction;

const Web3 = require('web3');
const web3 = new Web3('https://ropsten.infura.io/v3/e9595b79cb2d4128b8e2457fd0932edd');

const account1 = '0x6711D6D4e9511E8b69D6261218b31b3f5Ba72171';
const account2 = '0x09E78Ec232C168ec6ef420675F813C4719A811f8';

const privateKey1 = 'BA7C22B9F76802829C8B751B61FABDFBAFE8504A03E23814A79B59F09C41C833';
const privateKey2 = '3D84D21DD7B6AC5F0B3BFEB35BB05ACB4F70F7B462AAB72B531F6D78B090486E';

const privateKey1Buffer = Buffer.from(privateKey1, 'hex');
const privateKey2Buffer = Buffer.from(privateKey2, 'hex');

console.log("Buffer 1 = ", privateKey1Buffer);
console.log("Buffer 2 = ", privateKey2Buffer);

web3.eth.getTransactionCount(account1, (err, txCount) => {
    //Build Transaction
    let txObject = {
        nonce: web3.utils.toHex(txCount),
        to: account2,
        value: web3.utils.toHex(web3.utils.toWei('0.5', 'ether')),
        gasLimit: web3.utils.toHex(21000),
        gasPrice: web3.utils.toHex(web3.utils.toWei('10', 'gwei'))
    }

    //Sign Transaction
    const tx = new Tx(txObject, { chain: 'ropsten', hardfork: 'petersburg' });
    tx.sign(privateKey1Buffer);

    const serializedTx = tx.serialize();
    const raw = '0x' + serializedTx.toString('hex');

    //Broadcast Transaction
    web3.eth.sendSignedTransaction(raw, (err, txHash) => {
        console.log('txHash = ', txHash);
    });
});