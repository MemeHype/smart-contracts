//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Token} from "./Token.sol";

contract TokenFactory {
    uint constant public DECIMALS = 10 ** 18;
    uint constant public MAX_SUPPLY = (10 ** 9) * DECIMALS;
    uint constant public INITIAL_MINT = MAX_SUPPLY * 20 /100;
    mapping(address => bool) public tokens;

    function createToken(string memory name, string memory ticker) external returns(address deploymentaddress)
    {
        Token token = new Token(name,ticker,INITIAL_MINT);
        tokens[address(token)] = true;
        return address(token);
        }
        function buy(address tokenAddress, uint amount) external payable{
            require(tokens[tokenAddress] ==true, "token does not exist");
            Token token = Token(tokenAddress);
            uint availableSupply = MAX_SUPPLY - INITIAL_MINT - token.totalSupply();
            require(amount <= availableSupply,"not enough available supply");
            uint requiredEth = calculateRequiredhbar(tokenAddress, amount);

        }
        function calculateRequiredhbar(address tokenAddress, uint amount) internal returns (uint)
        {

             Token token = Token(tokenAddress);
            /* uint b = token.totalSupply()+amount;
             uint a = token.totalSupply();
             uint f_a = k * a +offset;
             uint f_b = k * b + offset;
             return (b-a) * (f_a) + */
        }
        }