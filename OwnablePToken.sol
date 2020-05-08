pragma solidity ^0.6.0;

import "./IERC20.sol";
import "./SafeMath.sol";
// SafeMath library will allow to use arthemtic operation on uint256

contract OwnablePToken is IERC20 {
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
    
    //events
    event OwnerChanged(
        bool success,
        address newContractOwner,
        uint256 amount
    );
    
    /**
     * Function modifier to restrict Owner's transactions.
     */
    modifier onlyOwner() {
        require(msg.sender == contractOwner, "M-P-Token: Only contract owner allowed");
        _;
    }
    
    constructor() public {
        name = "Ownable Practice Token";
        symbol = "O-P-Token";
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
    function totalSupply() external view override returns(uint256) {
        return _totalSupply;
    }
    
    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) external view override returns(uint256) {
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
        
        require(sender != address(0), "O-P-Token: transfer from the zero address");
        require(recipient != address(0), "O-P-Token: transfer to the zero address");
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
        
        require(tokenOwner != address(0), "O-P-Token: approve from the zero address");
        require(spender != address(0), "O-P-Token: approve to the zero address");
        
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
        
        require(sender != address(0), "O-P-Token: transfer from the zero address");
        require(recipient != address(0), "O-P-Token: transfer to the zero address");
        require(_balances[sender] > amount, "O-P-Token: transfer amount exceeds balance");
        require(_allowance > amount, "O-P-Token: transfer amount exceeds allowance");
        
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
     * This function will allow owner to change ownership to another valid address
     * 
     * Requirements:
     * - the caller must be Owner of Contract
     * - thw new owner must be valid
     * - amount must be valid
     */
    function changeOwner(address newContractOwner, uint256 amount) public onlyOwner() returns(bool) {
        require(newContractOwner != address(0), "O-P-Token: Address must be valid");
        require(amount > 0, "O-P-Token: Amount must be valid");
        if(newContractOwner == contractOwner) {
            revert("O-P-Token: The provided address is already the owner");
        }
        
        transfer(payable(newContractOwner), amount);
        
        contractOwner = newContractOwner;
        
        //event fired
        emit OwnerChanged(true, newContractOwner, _balances[newContractOwner]);
        
        return true;
    } 
}