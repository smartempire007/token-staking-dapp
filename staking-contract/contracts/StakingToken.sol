// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract StakingToken is ERC20 {
    using SafeMath for uint256;

    // address public owner;
    address public owner;

    uint256 public minStakePeriod = 60 * 60 * 24 * 7;
    uint256 public tokenToWeiRate; // 1 / 10000000000

    uint256 public rewardPct = 1;

    event TokenPurchase(address indexed purchaser, uint256 amount);
    event Staked(
        address indexed _staker,
        uint256 indexed _timestamp,
        uint256 _amount
    );
    event Claimed(
        address indexed _claimer,
        uint256 indexed _timestamp,
        uint256 _amount
    );

    mapping(address => uint256) private _staked;
    mapping(address => uint256) private _rewardDueDate;

    // MODIFIERS
    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner can call this function");
        _;
    }
    modifier hasSufficientBalance(address _addr, uint256 _amount) {
        require(
            _amount <= (balanceOf(_addr) - _staked[_addr]),
            "Insufficient account/token Balance"
        );
        _;
    }

    modifier rewardIsDue(address _addr) {
        require(
            block.timestamp >= _rewardDueDate[_addr],
            "Required date for claiming a reward has not been reached"
        );
        _;
    }

    // STANDARD FUNCTIONS
    constructor(uint256 _stakeTime, uint256 _tokenToWeiRate)
        payable
        ERC20("TakingToken", "STK")
    {
        owner = msg.sender;
        minStakePeriod = _stakeTime;
        tokenToWeiRate = _tokenToWeiRate;
        safeMint(owner, 1000 * (10**decimals()));
    }

    receive() external payable {
        uint256 tokenAmount = _calcTokensBought(msg.value);
        safeMint(msg.sender, tokenAmount);
    }

    // PUBLIC FUNCTIONS
    function buyToken(uint256 tokensBought) public payable {
        require(msg.value > 0, "You have to send some ETH");
        payable(owner).transfer(msg.value);
        tokensBought = _calcTokensBought(msg.value);
        safeMint(msg.sender, tokensBought);
        emit TokenPurchase(msg.sender, tokensBought);

        // return (true, tokensBought);
    }

    function stakeToken(uint256 _amtToStake)
        public
        hasSufficientBalance(msg.sender, _amtToStake)
        returns (bool, uint256 rewardTime)
    {
        _rewardDueDate[msg.sender] = block.timestamp + minStakePeriod;
        _staked[msg.sender] += _amtToStake;
        rewardTime = _rewardDueDate[msg.sender];
        _burn(msg.sender, _amtToStake);
        return (true, rewardTime);
    }

    function claimReward() public rewardIsDue(msg.sender) returns (bool) {
        _rewardDueDate[msg.sender] = block.timestamp + minStakePeriod;
        uint256 reward = _calcReward(msg.sender);
        safeMint(msg.sender, reward);
        return true;
    }

    function modifyTokenBuyPrice(uint256 _tokenToWeiRate)
        public
        onlyOwner
        returns (bool)
    {
        tokenToWeiRate = _tokenToWeiRate;
        return true;
    }

    // INTERNAL UTILITY FUNCTIONS
    function safeMint(address _receiver, uint256 _amount)
        internal
        returns (bool)
    {
        _mint(_receiver, _amount);
        return true;
    }

    function _calcTokensBought(uint256 _msgValue)
        internal
        view
        returns (uint256 tokenAmount)
    {
        require(_msgValue >= tokenToWeiRate, "Insufficient ETH to buy tokens");
        tokenAmount = _msgValue + tokenToWeiRate;
        return tokenAmount;
    }

    function _calcReward(address _addr)
        internal
        view
        returns (uint256 rewardAmount)
    {
        rewardAmount = (_staked[_addr] * rewardPct) / 100;
        return rewardAmount;
    }
}
