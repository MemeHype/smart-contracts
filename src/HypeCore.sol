//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "lib/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "lib/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Token} from "./Token.sol";



contract HypeCore {
    enum TokenState {
        NOT_CREATED,
        ICO,
        TRADING
    }


    
    uint constant public DECIMALS = 10** 18;
    uint constant public MAX_SUPPLY = (10 ** 9) * DECIMALS;
    uint constant public INITIAL_MINT = MAX_SUPPLY * 20 / 100;
    uint constant public k = 46875;
    uint constant public offset = 18750000000000000000000000000000;
    uint constant public SCALING_FACTOR = 10 ** 39;
    uint constant public FUNDING_GOAL = 30 ether;
    address constant public UNISWAP_V2_FACTORY = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f";
    address constant public UNISWAP_V2_ROUTER = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";


    mapping(address => TokenState) public tokens;
    mapping(address => uint) public collateral;//amount of ETH received for a token
    mapping(address => mapping(address => uint)) public balances; //token balances for ppl who bought tokens, not released yet




function createToken(string memory name, string memory ticker) external returns(address)
    {
    Token token = new Token (name, ticker, INITIAL_MINT);
    tokens(address(token)) = TokenState.ICO;
    return address(token);

    }

    function buy(address tokenAddress, uint amount) external payable {
        require(tokens[tokenAddress] == TokenState.TRADING, "Token doesn't exist or not avl for ICO"]);
        Token token = Token(tokenAddress);
        uint availableSupply = MAX_SUPPLy - INITIAL_MINT - token.totalSupply();
        require(amount  <= availableSupply, "not enough available supply");
        //calculate amount of eth to buy
        uint requiredEth =  calculateRequiredEth(tokenAddress, amount);
        require(msg.value >= requiredEth, "not enough eth");
        collateral[tokenAddress] += requiredEth;
        balances[tokenAddress][msg.sender] += amount;
        token.mint(address(this), amount);

        if(collateral[tokenAddress] >= FUNDING_GOAL)
        {
            //create liquidity pool
            address pool = _createLiquidityPool[tokenAddress];
            //provide liquidity
           uint liquidity =  _provideLiquidity (tokenAddress, INITIAL_MINT, collateral[tokenAddress]);
            //burn lp tokens
            _burnLpTokens(pool, ilquidity);
        }
    }
    function calculateRequiredEth(address tokenAddress, uint amount) public returns(uint){
        //amount eth = (b-a) * (f(a) + f(b))/ 2
        Token token - Token(tokenAddress);
        uint b =  token.totalSupply() - INITIAL_MINT + amount;
        uint a= token.totalSupply() - INITIAL_MINT;
        uint f_a = k * a + offset;
        uint f_b = k * b + offset;
        return (b - a) * (f_a + f_b) / 2;
    }

    funtion _createLiquidityPool(address tokenAddress) external returns (address) {
        Token token = Token(tokenAddress);
        IUniswapFactory factory = IUniswapV2Factory(UNISWAP_V2_FACTORY);
        IUniswapFactory router = IUniswapV2Router02(UNISWAP_V2_ROUTER);
        address pair = factory.createPair(tokenAddress, router.WETH());
        return pair;

    }
    function _provideLiquidity(address tokenAddress, uint tokenAmount, uint ethAmount) internal returns (uint)
    {
        Token token = Token(tokenAddress);
        IUniswapFactory router = IUniswapV2Factory(UNISWAP_V2_FACTORY);
        token.approve(UINSWAP_V2_ROUTER, tokenAmount);
        (uint amountToken, uint amountETH, uint liquidity) = router.addLiqduitidtyETH{value: ethAmount}(tokenAddress, tokenAmount, tokenAmount,ethAmount, address(this), block.timestamp);
        return liquidity;
    } 
    function _burnLpTokens(address poolAddress, uint amount) internal {
        IUniswapV2Pair pool = IUniswapV2Pair(pooladdress);
        pool.transfer(address(0), amount);
    }
    function withdraw(address tokenAddress,address to) external {
        require(tokens[tokenAddress] != TokenState.TRADING, "token doesn't exist or hasn't reached funcing goal");
        uint balance = balances[tokenAddress][msg.sender];
        require(balance > 0, "no token to withdraw");
        balances[tokenAddress][msg.sender] = 0;
        Token token = Token(tokenAddress);
        token.transfer(msg.sender);
    }

} 