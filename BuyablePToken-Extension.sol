pragma solidity ^0.6.0;

import "./IERC20.sol";
import "./SafeMath.sol";
import "./Address.sol";
// SafeMath library will allow to use arthemtic operation on uint256

contract BuyablePExtToken is IERC20 {
    //owner, sender both are same name for tokenOwner
    //everything is in wei system, msg.value and also 1 token = 10^18 weiToken
    
    //Extending uint256 with SafeMath Library.
    using SafeMath for uint256;
    
    //Extending address with Address Library.
    using Address for address;
    
    address public contractAddress = address(this);
    address public contractOwner;
    address public delegate;
    
    //mapping to keep balances
    mapping (address => uint256) private _balances;
    
    //mapping to keep allowances
    //      tokenOwner           spender    amount
    mapping (address => mapping (address => uint256)) private _allowances;
    
    //mapping to keep time when token is bought
    mapping (address => uint256) public timeOfBoughtTokens;
    
    
    //the amount of tokens in existence
    uint256 private _totalSupply;
    
    //price of tokens
    uint256 public tokenPrice;

    string public name;
    string public symbol;
    uint256 public decimals;
    
    
    //events
    event PriceAdjusted(
        bool success,
        uint256 price
    );
    
    event TokensSold(
        address owner,
        address recipient,
        uint256 numberOfTokens
    );
    
    event tokensReturned(
        uint256 _numberOfWeiTokens,
        address tokenOwner,
        uint256 _amount
    );
    
    event OwnerChanged(
        bool success,
        address newContractOwner,
        uint256 amount
    );
    
    event Delegation(
        bool success,
        address _delegate
    );
    
    event AmountWithDraw(
        bool success,
        address contractOwner,
        uint256 amount
    );
    
    
    event AmountReceived(string);
    
    
    constructor(uint256 _price) public {
        require(_price > 0, "B-Ex-P-Token: token price must be valid");
        
        name = "Buyable-Extension Practice Token";
        symbol = "B-Ex-P-Token";
        decimals = 18;
        contractOwner = msg.sender;
        tokenPrice = _price;
        
        //1 million tokens generated
        _totalSupply = 1000000 * (10 ** decimals);
        
        //transfer totalsupply to contractOwner
        _balances[contractOwner] = _totalSupply;
        
        //emit Transfer event
        emit Transfer(address(this), contractOwner, _totalSupply);
    }
    
    
    /**
     * Function modifier to restrict Owner's transactions.
     */
    modifier onlyOwner() {
        require(msg.sender == contractOwner, "B-Ex-P-Token: Only contract owner allowed");
        _;
    }
    
    
    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() external view override returns(uint256) {
        return _totalSupply;
    }
    
    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns(uint256) {
        return _balances[account]; 
    }
    
    
    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     * 
     * - `sender` and `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public override returns(bool) {
        address sender = msg.sender;
        
        require(sender != address(0), "B-Ex-P-Token: transfer from the zero address");
        require(recipient != address(0), "B-Ex-P-Token: transfer to the zero address");
        require(_balances[sender] > amount, "B-Ex-P-Token: Insufficient balance");
        
        //decrease the balance of token sender account
        _balances[sender] = _balances[sender].sub(amount); 
        
        //increase the balance of token recipient account
        _balances[recipient] = _balances[recipient].add(amount);
        
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    
    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address tokenOwner, address spender) external view override returns(uint256) {
        return _allowances[tokenOwner][spender];
    } 
    
    
    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) external override returns(bool) {
        address tokenOwner = msg.sender;
        
        require(tokenOwner != address(0), "B-Ex-P-Token: approve from the zero address");
        require(spender != address(0), "B-Ex-P-Token: approve to the zero address");
        require(_balances[tokenOwner] >= amount, "B-Ex-P-Token: caller is either not the tokenOwner or has insufficient balance");
        
        _allowances[tokenOwner][spender] = amount;
        
        emit Approval(tokenOwner, spender, amount);
        return true;
    }
    
    
    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     * here sender is the tokenOwner
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller(spender) must have allowance for ``sender``'s tokens of at least `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external override returns(bool) {
        address spender = msg.sender;
        uint256 _allowance = _allowances[sender][spender];
        
        require(sender != address(0), "B-Ex-P-Token: transfer from the zero address");
        require(recipient != address(0), "B-Ex-P-Token: transfer to the zero address");
        require(_balances[sender] > amount, "B-Ex-P-Token: transfer amount exceeds balance");
        require(_allowance > amount, "B-Ex-P-Token: transfer amount exceeds allowance");
        
        //deducting the allowance
        _allowance = _allowance.sub(amount);
        
        // ---Transfer execution---
        
        //transfer token to recipient;
        _balances[recipient] = _balances[recipient].add(amount);
        
        //owner decrease balance
        _balances[sender] =_balances[sender].sub(amount); 
        
        emit Transfer(sender, recipient, amount);
        // ---end execution--
        
        //decrease the approval amount
        _allowances[sender][spender] = _allowance;
        
        emit Approval(sender, spender, amount);
        
        return true;
    }
    
    /**
     * This function is to adjust the price of token
     *
     * Requirements:
     * - function only restricted to owner
     * - price must be valid
     */
    function adjustPrice(uint256 _price) public returns(bool) {
        require((msg.sender == contractOwner) || (msg.sender == delegate), "B-Ex-P-Token: Only contract owner or delegate allowed");
        require(_price > 0, "B-Ex-P-Token: token price must be valid");
        
        tokenPrice = _price;
        
        emit PriceAdjusted(true, _price);
        return true;
    }
    
    /**
     * This function lets buyer to buy tokens
     *
     * Requirements:
     * - function only restricted to EOA
     * - `recipient` must be valid
     * - numberOfTokens to be bought must be valid
     * - contract owner must have equal or greater tokens than the tokens to be bought
     */
    function buyToken() public payable returns(bool) {
        address _recipient = msg.sender;
        
        require(Address.isContract(_recipient) == false, "B-Ex-P-Token: Buyer cannot be a contract");
        require(_recipient != address(0), "B-Ex-P-Token: transfer to the zero address");
        require(msg.value > 0, "B-Ex-P-Token: amount must be valid");
        
        //uint256 _numberOfTokens = msg.value.div(tokenPrice);
        
        uint256 _numberOfWeiTokens = (msg.value.mul(10**decimals)).div(tokenPrice);
       
        require(_numberOfWeiTokens > 0, "B-Ex-P-Token: number of tokens must be valid");
        require(_balances[contractOwner] >= _numberOfWeiTokens, "B-Ex-P-Token: insufficient tokens");
        
        //decrease the balance of tokens of contractOwner
        _balances[contractOwner] = _balances[contractOwner].sub(_numberOfWeiTokens); 
        
        //increase the balance of token recipient account
        _balances[_recipient] = _balances[_recipient].add(_numberOfWeiTokens);
        
        //saving the timestamp for later return check
        timeOfBoughtTokens[_recipient] = block.timestamp;
        
        emit TokensSold(contractOwner, _recipient, _numberOfWeiTokens);
        return true;
    }
    
    /**
     * This function will allow to get balance of contract
     * 
     * Requirements:
     * - the caller must be valid
     */
    function getContractBalance() public view returns (uint256) {
        require(msg.sender != address(0), "B-Ex-P-Token: Address must be valid");
        return address(this).balance;
    }
    
    /**
     * This function will allow owner to withdraw ethers stored in contact
     * 
     * Requirements:
     * - the caller must be Owner of Contract
     * - amount must be valid
     */
    function withDraw(uint256 _amount) public onlyOwner() returns(bool) {
        require(_amount > 0, "B-Ex-P-Token: Amount must be valid");
        require(_amount <= address(this).balance, "B-Ex-P-Token: Insufficient Balance");
        
        payable(contractOwner).transfer(_amount);
        
        //event fire
        AmountWithDraw(true, contractOwner, _amount);
        
        return true;
    } 
    
    /**
     * This function will allow owner to change ownership to another valid address
     * 
     * Requirements:
     * - the caller must be Owner of Contract
     * - thw new owner must be valid
     * - amount must be valid
     */
    function changeOwner(address newContractOwner, uint256 amount) public onlyOwner() returns(bool) {
        require(newContractOwner != address(0), "B-Ex-P-Token: Address must be valid");
        require(amount > 0, "B-Ex-P-Token: Amount must be valid");
        if(newContractOwner == contractOwner) {
            revert("B-Ex-P-Token: The provided address is already the owner");
        }
        
        transfer(payable(newContractOwner), amount);
        
        contractOwner = newContractOwner;
        
        //event fired
        emit OwnerChanged(true, newContractOwner, _balances[newContractOwner]);
        
        return true;
    } 
    
    /**
     * This function will allow owner to delegate a person to adjustPrice of the token
     * 
     * Requirements:
     * - the caller must be Owner of Contract
     * - delegate must be valid
     */
    function approveDelegate(address _delegate) public onlyOwner() returns(bool) {
        require(_delegate != address(0), "B-Ex-P-Token: Address must be valid");
        
        delegate = _delegate;
        
        emit Delegation(true, _delegate);
        return true;
    }
    
    /**
     * This function will allow token owner to return tokens based on current pricing
     * 
     * Requirements:
     * - the caller must be Owner of token
     * - numberOfTokens must be valid
     * - can return only within a month
     */
    function returnToken(uint256 _numberOfWeiTokens) public returns(bool) {
        address tokenOwner = msg.sender;
        
        require(tokenOwner != address(0), "B-Ex-P-Token: caller cannot be zero address");
        require(_balances[tokenOwner] >= _numberOfWeiTokens, "B-Ex-P-Token: caller is either not the tokenOwner or has insufficient balance");
        
        require(block.timestamp <= (timeOfBoughtTokens[tokenOwner]).add(300), "B-Ex-P-Token: Return only possible within the limited time"); //1 month = 2592000 secs
        //                                                              ^ 5 min
        
        //converts numberOfTokens to value(money) based on current tokenPrice
        uint256 _amount = (_numberOfWeiTokens.mul(tokenPrice)).div(10**decimals);
        
        require(_amount > 0, "B-Ex-P-Token: Amount must be valid");
        require(_amount <= address(this).balance, "B-Ex-P-Token: Insufficient Balance");
        
        //transfers tokens back to contractOwner 
        transfer(contractOwner, _numberOfWeiTokens);
        
        //transfers money back to the tokenOwner
        payable(msg.sender).transfer(_amount);
        
        //event fire
        emit tokensReturned(_numberOfWeiTokens, tokenOwner, _amount);
        
        return true;
    }
    
    /**
     * This is fallback function and sends tokens if anyone sends ether
     *
     * - if anyone sends 1 wei than 100 tokens will be transferred to him/her if 
     * tokenPrice is 0.01 ether i.e 10000000000000000 wei (subject to change with tokenPrice)
     */
    fallback() external payable {
        buyToken();
        emit AmountReceived("fallback");
    }
    
    receive() external payable {
        buyToken();
        emit AmountReceived("receive fallback");
    }
    
}