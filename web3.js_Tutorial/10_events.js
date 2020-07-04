const Web3 = require('web3');
const web3 = new Web3('wss://ropsten.infura.io/ws/v3/e9595b79cb2d4128b8e2457fd0932edd');

const contractAddress = '0x32b4F57D9C2dFc90C9BB6c762a76E7a5834D0294';
const abi = [
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
        "stateMutability": "nonpayable",
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
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "internalType": "string",
                "name": "",
                "type": "string"
            }
        ],
        "name": "logString",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "name": "logUint",
        "type": "event"
    },
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
    }
];

const contract = new web3.eth.Contract(abi, contractAddress);

//// once ////

// fromBlock doesnot work on once 
contract.once(
    'logString',            // event name argument
    {                       // filter-object argument (optional)    
        fromBlock: 0,
        toBlock: 'latest'
    },
    (error, event) => {       // callback function
        console.log('Error: ', error);
        console.log('Event: ', event);
    }
);

contract.once(
    'logString',            // event name argument
    (error, event) => {       // callback function
        console.log('Error: ', error);
        console.log('Event: ', event);
    }
);

contract.once('logUint', (error, event) => {
    console.log('Error: ', error);
    console.log('Event: ', event);
});


//// events ////

contract.events.logUint({
    fromBlock: 0
}, function(error, event) { console.log('Event: ', event); });

contract.events.logUint({
    fromBlock: 'genesis'
},
function(error, event) {
    console.log('Event: ', event); 
})
.on('connected', function(result) {
    console.log('Connected: ', result);
})
.on('data', function(event) {
    console.log('Data: ', event);
})
.on('changed', function(event) {
    console.log('Changed: ', event);
})
.on('error', function(error, receipt) {
    console.log('Error: ', error);
    console.log('Receipt: ', receipt);
});


//// events.allEvents ////

contract.events.allEvents(function(error, events) {
    console.log('Events: ', events);
})
.on('connected', function(result) {
    console.log('Connected: ', result);
})
.on('data', function(events) {
    console.log('Data: ', events);
})
.on('changed', function(events) {
    console.log('events: ', events);
})
.on('error', function(error, receipt) {
    console.log('Error: ', error);
    console.log('receipt: ', receipt);
});


//// getPastEvents ////

contract.getPastEvents('allEvents', {
    fromBlock: 'genesis',
    toBlock: 'latest'
}, (error, events) => { console.log('Events: ', events); })
.then(function(events) {
    console.log('Events: ', events);
});