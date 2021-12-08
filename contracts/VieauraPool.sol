// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract VieauraPool is Ownable {
    mapping(address => address) public tokenPriceFeedMapping;
    mapping(address => mapping(address => uint256)) allowed;
    address[] public allowedTokens;
    uint256 daiBalance;
    IERC20 public vieauraToken;
    AggregatorV3Interface internal daiPriceFeed;

    event Approval(address owner, address spender, uint256 value);

    constructor(address _VieauraTokenAddress) public {
        vieauraToken = IERC20(_VieauraTokenAddress);
        daiPriceFeed = AggregatorV3Interface(
            0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9
        );
    }

    function deposit(uint256 _amount) public payable {
        require(_amount > 0, "Amount must be greater than 0");
        require(
            IERC20(allowedTokens[0]).balanceOf(msg.sender) >= _amount,
            "Insufficient Dai Tokens."
        );
        IERC20(allowedTokens[0]).transferFrom(
            msg.sender,
            address(this),
            _amount
        );
        daiBalance = daiBalance + _amount;
        vieauraToken.transfer(msg.sender, _amount);
    }

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    function approve(address _spender, uint256 _amount) public returns (bool) {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function withdraw(uint256 _amount) public payable {
        require(
            vieauraToken.balanceOf(msg.sender) >= _amount,
            "Insufficient amount of VARA tokens."
        );
        require(daiBalance >= _amount, "Insufficient Dai Token supply.");
        vieauraToken.transferFrom(msg.sender, address(this), _amount);
        IERC20(allowedTokens[0]).transferFrom(
            address(this),
            msg.sender,
            _amount
        );
    }

    function exchangeRate() public returns (int) {
        int daiPrice = getLatestDaiPrice();
        int vieauraPrice = getVieauraTokenPrice(); 
        int rate = daiPrice / vieauraPrice; 
        return rate;
    }

    function setPriceFeedContract(address _token, address _priceFeed)
        public
        onlyOwner
    {
        tokenPriceFeedMapping[_token] = _priceFeed;
    }

    function addAllowedTokens(address _token) public onlyOwner {
        allowedTokens.push(_token);
    }

    function tokenIsAllowed(address _token) public returns (bool) {
        for (
            uint256 allowedTokensIndex = 0;
            allowedTokensIndex < allowedTokens.length;
            allowedTokensIndex++
        ) {
            if (allowedTokens[allowedTokensIndex] == _token) {
                return true;
            }
        }
        return false;
    }

    function getLatestDaiPrice() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = daiPriceFeed.latestRoundData();
        return price;
    }

    function getVieauraTokenPrice() public view returns (int) {
        return 1; 
    }
}
