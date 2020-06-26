var Tx = require('ethereumjs-tx').Transaction;
const Web3 = require('web3');
const web3 = new Web3('https://ropsten.infura.io/v3/e9595b79cb2d4128b8e2457fd0932edd');


const account2 = '0x09E78Ec232C168ec6ef420675F813C4719A811f8';
const privateKey2 = '3D84D21DD7B6AC5F0B3BFEB35BB05ACB4F70F7B462AAB72B531F6D78B090486E';
const privateKey2Buffer = Buffer.from(privateKey2, 'hex');

let contractAddress = '0x208ae3a3Ed6B16545aCd8e0893F4b9F62E9E7D4D';
let abi = [
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_age",
				"type": "uint256"
			}
		],
		"name": "setAge",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "doSomeWork",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "pure",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getAge",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
];

const contract = new web3.eth.Contract(abi, contractAddress);

contract.methods.getAge().call((err, age) => {
    console.log('Age = ', age);
});

web3.eth.getTransactionCount(account2, (err, txCount) => {
    let txObject = {
        nonce: web3.utils.toHex(txCount),
        gasLimit: web3.utils.toHex(80000),
        gasPrice: web3.utils.toHex(web3.utils.toWei('10', 'gwei')),
        to: contractAddress,
        data: contract.methods.setAge(89).encodeABI()
    }

    const tx = new Tx(txObject, { chain: 'ropsten', hardfork: 'petersburg' });
    tx.sign(privateKey2Buffer);

    const serializedTx = tx.serialize();
    const raw = '0x' + serializedTx.toString('hex');

    web3.eth.sendSignedTransaction(raw, (err, txHash) => {
        console.log('txHash = ', txHash);
    });
});