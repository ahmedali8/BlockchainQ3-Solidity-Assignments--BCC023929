pragma solidity ^0.6.0;

import "./IERC20.sol";
import "./SafeMath.sol";
// SafeMath library will allow to use arthemtic operation on uint256

contract PausablePToken is IERC20 {
    //owner, sender both are same name for tokenOwner
    
    //Extending uint256 with SafeMath Library.
    using SafeMath for uint256;
    
    address public contractOwner;
    
    //mapping to keep balances
    mapping (address => uint256) private _balances;
    
    //mapping to keep allowances
    //      tokenOwner           spender    amount
    mapping (address => mapping (address => uint256)) private _allowances;
    
    //the amount of tokens in existence
    uint256 private _totalSupply;
    
    string public name;
    string public symbol;
    uint8 public decimals;
    
    bool active = false;

    
    /**
     * Function modifier to restrict Owner's transactions.
     */
    modifier onlyOwner() {
        require(msg.sender == contractOwner, "M-P-Token: Only contract owner allowed");
        _;
    }
    
    /**
     * Function modifier to pause the token
     */
    modifier isActive() {
        require(active == true, "M-P-Token: Token is paused");
        _;
    }
    
    constructor() public {
        name = "Mintable Practice Token";
        symbol = "M-P-Token";
        decimals = 3;
        contractOwner = msg.sender;
        
        //1 million tokens generated
        _totalSupply = 1000000 * (10 ** uint256(decimals));
        
        //transfer totalsupply to contractOwner
        _balances[contractOwner] = _totalSupply;
        
        //emit Transfer event
        emit Transfer(address(this), contractOwner, _totalSupply);
    }
    
    
    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() external view override isActive() returns(uint256) {
        return _totalSupply;
    }
    
    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) external view override isActive() returns(uint256) {
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
    function transfer(address recipient, uint256 amount) external override isActive() returns(bool) {
        address sender = msg.sender;
        
        require(sender != address(0), "M-P-Token: transfer from the zero address");
        require(recipient != address(0), "M-P-Token: transfer to the zero address");
        require(_balances[sender] > amount);
        
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
    function allowance(address tokenOwner, address spender) external view override isActive() returns(uint256) {
        return _allowances[tokenOwner][spender];
    } 
    
    
    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) external override isActive() returns(bool) {
        address tokenOwner = msg.sender;
        
        require(tokenOwner != address(0), "M-P-Token: approve from the zero address");
        require(spender != address(0), "M-P-Token: approve to the zero address");
        
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
    function transferFrom(address sender, address recipient, uint256 amount) external override isActive() returns(bool) {
        address spender = msg.sender;
        uint256 _allowance = _allowances[sender][spender];
        
        require(sender != address(0), "M-P-Token: transfer from the zero address");
        require(recipient != address(0), "M-P-Token: transfer to the zero address");
        require(_balances[sender] > amount, "M-P-Token: transfer amount exceeds balance");
        require(_allowance > amount, "M-P-Token: transfer amount exceeds allowance");
        
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
     * This function will allow owner to pause the tokens.
     * 
     * Requirements:
     * - the caller must be Owner of Contract
     */
    function PauseToken() public onlyOwner() returns(bool) {
        active = false;
        
        return true;
    } 
    
    /**
     * This function will allow owner to activate the tokens.
     * 
     * Requirements:
     * - the caller must be Owner of Contract
     */
    function ActivateToken() public onlyOwner() returns(bool) {
        active = true;
        
        return true;
    } 
}