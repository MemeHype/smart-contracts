//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {ERC20} from "@openzeppelin-contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin-contracts/access/Ownable.sol";

contract Token is ERC20,Ownable  {
    address public admin;
    constructor (string memory name, string memory ticker, uint256 initialMint) ERC20(name, ticker) Ownable(msg.sender)
{
    _mint(msg.sender, initialMint); 
    admin = msg.sender;
    
}
function mint(address to, uint amount) external{
    require(msg.sender == admin, "only admin can mint");
    _mint(to,amount);
}  
}