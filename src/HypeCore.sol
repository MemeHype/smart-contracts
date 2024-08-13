//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Token} from "./Token.sol";

interface IHTS {
    function createToken(string memory name, string memory symbol,uint256 initialSupply) external returns (address);
    function associateToken(address token,address account) external;
    function transferToken(addreess token, address to, uint256 amount) external'
}

contract HypeCore is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    struct Token {
        uint256 initialBalance;
        uint256 balance;
        uint256 availableTokenBalance;
        bool isActive;
        bool isLpCreated;
    }
    uint constant public DECIMALS = 10 ** 18;
    uint constant public INITIAL_SUPPLY = (10 ** 9) * DECIMALS;
    uint256 private constant BASIS_POINTS = 10000;

    uint constant public INITIAL_MINT = MAX_SUPPLY * 20 /100;
    mapping(address => bool) public tokens;
    address public treasure;
    uint256 public initialBalance;
    uint256 public availableTokenBalance;
    uint256 public createFee;
    uint96 public commissionRate;
    uint96 public finalRate;

    mapping(address => Token) public balances;

    address public lpAddress;
    address public currency;
    address public admin; address public treasure;
    uint256 public initialBalance;
    uint256 public availableTokenBalance;
    uint256 public createFee;
    uint96 public commissionRate;
    uint96 public finalRate;

    mapping(address => Token) public balances;

    address public lpAddress;
    address public currency;
    address public admin;



    function createToken(string memory name, string memory symbol) external returns(address ERC20)
    {
        Token token = new Token(name,ticker,1000000000);
        address tokenAddress = address(newToken);
        balances[tokenAddress].balance = initialBalance;
        balances[tokenAddress].initialBalance = initialBalance;
        balances[tokenAddress].availableTokenBalance = availableTokenBalance;
        balances[tokenAddress].isActive = true;
        ILP(tokenAddress).renounceOwnership();
        emit Create(tokenAddress, initialBalance, availableTokenBalance);
        return newToken;
    }
    function createTokenWithBuy(
        string memory name,
        string memory symbol
    ) external payable nonReentrant {
        require(msg.value > 0, "ETH amount must be greater than zero");

        ERC20 newToken = new YourMemeToken(name, symbol, 1000000000);
        address tokenAddress = address(newToken);
        balances[tokenAddress].balance = initialBalance;
        balances[tokenAddress].initialBalance = initialBalance;
        balances[tokenAddress].availableTokenBalance = availableTokenBalance;
        balances[tokenAddress].isActive = true;
        ILP(tokenAddress).renounceOwnership();

        uint256 receivedAmount = (msg.value * 10000) / (10000 + commissionRate);

        uint256 tokenReserveBalance = getReserve(tokenAddress);
        uint256 stopBalance = (1000000000 ether -
            balances[tokenAddress].availableTokenBalance);

        uint256 fee = msg.value - receivedAmount;
        uint256 tokensToReceive = getInputPrice(
            receivedAmount,
            balances[tokenAddress].balance,
            tokenReserveBalance
        );

        uint256 reserveBalanceAfterTxCompleted = (tokenReserveBalance -
            tokensToReceive);

        uint256 refund;
        if (reserveBalanceAfterTxCompleted < stopBalance) {
            tokensToReceive = tokenReserveBalance - stopBalance;
            reserveBalanceAfterTxCompleted = stopBalance;
            receivedAmount = getOutputPrice(
                tokensToReceive,
                balances[tokenAddress].balance,
                tokenReserveBalance
            );
            fee = _getPortionOfBid(receivedAmount, commissionRate);
            require(
                msg.value >= (fee + receivedAmount),
                "insufficient payment"
            );
            refund = msg.value - (fee + receivedAmount);
        }
        balances[tokenAddress].balance += receivedAmount;

        if (reserveBalanceAfterTxCompleted == stopBalance) {
            balances[tokenAddress].isActive = false;
        }

        emit CreateWithFirstBuy(
            tokenAddress,
            initialBalance,
            availableTokenBalance,
            tokensToReceive,
            receivedAmount,
            fee,
            reserveBalanceAfterTxCompleted
        );

        ERC20(tokenAddress).transfer(msg.sender, tokensToReceive);
        sendProtocolFeeToTreasure(fee);
        if (refund > 0) {
            (bool success, ) = payable(msg.sender).call{value: refund}("");
            require(success, "refund is failed");
        }
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

        }
        }