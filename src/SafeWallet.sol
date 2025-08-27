// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
}

interface IDroseraTrap {
    function shouldRespond(bytes[] calldata data) external view returns (bool, bytes memory);
}

contract SafeWallet {
    IERC20 public immutable token;
    address public owner;

    event Deposited(address indexed from, uint256 amount);
    event Withdrawn(address indexed to, uint256 amount);
    event SweptToVault(address indexed vault, uint256 amount, bytes reason);

    modifier onlyOwner() {
        require(msg.sender == owner, "NOT_OWNER");
        _;
    }

    constructor(IERC20 _token, address _owner) {
        token = _token;
        owner = _owner;
    }

    
    function depositToSelf(uint256 amount) external {
        
        emit Deposited(msg.sender, amount);
    }

    
    function withdraw(address to, uint256 amount) external onlyOwner {
        require(token.balanceOf(address(this)) >= amount, "INSUFFICIENT");
        bool ok = token.transfer(to, amount);
        require(ok, "TRANSFER_FAIL");
        emit Withdrawn(to, amount);
    }

    // Protect-and-sweep: consult guard; if guard says "trigger", sweep funds to vault (vault must be a contract that accepts token transfer)
    function protectAndSweep(address guard, bytes[] calldata samples, address vault, uint256 amount) external onlyOwner {
        address g = guard;
        if (g != address(0)) {
            (bool should, bytes memory payload) = IDroseraTrap(g).shouldRespond(samples);
            if (should) {
                // If trap triggers, transfer up to `amount` to vault
                uint256 bal = token.balanceOf(address(this));
                uint256 toSweep = amount > bal ? bal : amount;
                require(toSweep > 0, "NOTHING_TO_SWEEP");
                bool ok = token.transfer(vault, toSweep);
                require(ok, "TRANSFER_FAIL");
                
                (bool success,) = vault.call(abi.encodeWithSignature("notifyDeposit(address,uint256)", address(this), toSweep));
                
                emit SweptToVault(vault, toSweep, payload);
                return;
            }
        }
        revert("NO_TRIGGER");
    }
}
