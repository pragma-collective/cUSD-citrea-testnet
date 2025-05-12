//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CUSDToken is ERC20, Ownable {
    // Maximum supply of tokens (10 billion tokens with 18 decimals)
    uint256 public constant MAX_SUPPLY = 10_000_000_000 * 10**18;
    
    // Mapping to track whitelisted minters
    mapping(address => bool) public whitelistedMinters;
    
    // Event emitted when a minter is added or removed from whitelist
    event MinterStatusChanged(address indexed minter, bool status);
    
    constructor() ERC20("Citrea USD", "CUSD") Ownable(msg.sender) {
        // Add deployer to whitelist by default
        whitelistedMinters[msg.sender] = true;
        emit MinterStatusChanged(msg.sender, true);
    }

    /**
     * @dev Adds or removes an address from the minter whitelist
     * @param minter Address to update whitelist status for
     * @param status True to whitelist, false to remove from whitelist
     */
    function setMinterStatus(address minter, bool status) external onlyOwner {
        require(minter != address(0), "Invalid address");
        whitelistedMinters[minter] = status;
        emit MinterStatusChanged(minter, status);
    }
    
    /**
     * @dev Adds multiple addresses to the minter whitelist
     * @param minters Array of addresses to whitelist
     */
    function batchAddMinters(address[] calldata minters) external onlyOwner {
        for (uint256 i = 0; i < minters.length; i++) {
            require(minters[i] != address(0), "Invalid address");
            whitelistedMinters[minters[i]] = true;
            emit MinterStatusChanged(minters[i], true);
        }
    }

    /**
     * @dev Mints tokens to the specified address, only callable by whitelisted minters
     * @param to Address to mint tokens to
     * @param amount Amount of tokens to mint
     */
    function mint(address to, uint256 amount) public {
        // Check that caller is whitelisted
        require(whitelistedMinters[msg.sender], "Not authorized to mint");
        
        // Check that minting this amount won't exceed the max supply
        require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds maximum token supply");
        
        _mint(to, amount);
    }
}
