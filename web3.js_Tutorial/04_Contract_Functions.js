console.log(Web3);
const rpcURL = "https://ropsten.infura.io/v3/e9595b79cb2d4128b8e2457fd0932edd";
const web3 = new Web3(rpcURL);

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

let contractAddress = "0x208ae3a3Ed6B16545aCd8e0893F4b9F62E9E7D4D";

const contract = new web3.eth.Contract(abi, contractAddress);

// console.log("Contract ", contract);
// console.log("Methods ", contract.methods);
// console.log("doSomeWork ", contract.methods.doSomeWork);
// console.log("setAge ", contract.methods.setAge);
// console.log("getAge ", contract.methods.getAge);

// let age = contract.methods.getAge().call();
// console.log("Age ", age);

contract.methods.getAge().call(function (err, result) {
    console.log("Age = ", result);
});

contract.methods.doSomeWork().call(function (err, result) {
    console.log("Work = ", result);
});