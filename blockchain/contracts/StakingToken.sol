// SPDX-License-Identifier: MIT
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";



contract StakingToken is ERC20{

    using SafeMath for uint256;

    // address public owner;
    address public owner;

    uint256 public minStakePeriod = 60 * 60 * 24 * 7;
    uint256 public tokenToWeiRate; // 1 / 10000000000 

    uint256 public rewardPct = 1;


    
    event TokenPurchase(address indexed purchaser,  uint256 amount);
    event Staked(address indexed _staker, uint indexed _timestamp, uint _amount);
    event Claimed(address indexed _claimer, uint indexed _timestamp, uint _amount);


    mapping (address=>uint) private _staked;
    mapping (address=>uint) private _rewardDueDate;
    

    // MODIFIERS
    modifier onlyOwner(){
        require(msg.sender == owner, "Only Owner can call this function");
        _;
    }
    modifier hasSufficientBalance(address _addr,uint _amount){
        require(_amount <= (balanceOf(_addr) - _staked[_addr]), "Insufficient account/token Balance");
        _;
    }

    modifier rewardIsDue(address _addr){
        require(block.timestamp >= _rewardDueDate[_addr], "Required date for claiming a reward has not been reached");
        _;
    }

    // STANDARD FUNCTIONS
    constructor( uint256 _stakeTime, uint256 _tokenToWeiRate) ERC20("TakingToken", "STK") payable{
        owner = msg.sender;
        minStakePeriod = _stakeTime;
        tokenToWeiRate = _tokenToWeiRate ;
        safeMint(owner, 1000 * (10 ** decimals()));
    }

    receive() external payable {
        uint tokenAmount = _calcTokensBought(msg.value);
        safeMint(msg.sender, tokenAmount);
    }

    // PUBLIC FUNCTIONS
    function buyToken(uint tokensBought) public payable {
        require(msg.value > 0, "You have to send some ETH");
        payable(owner).transfer(msg.value);
        tokensBought = _calcTokensBought(msg.value);
        safeMint(msg.sender, tokensBought);
        emit TokenPurchase(msg.sender, tokensBought);

        // return (true, tokensBought);
    }

    function stakeToken(uint _amtToStake) public hasSufficientBalance(msg.sender, _amtToStake) returns(bool, uint rewardTime){
        _rewardDueDate[msg.sender] = block.timestamp + minStakePeriod;
        _staked[msg.sender] += _amtToStake;
        rewardTime = _rewardDueDate[msg.sender];
        _burn(msg.sender, _amtToStake);
        return (true, rewardTime);
    }

    function claimReward() rewardIsDue(msg.sender) public returns(bool)
    {
        _rewardDueDate[msg.sender] = block.timestamp + minStakePeriod;
        uint reward = _calcReward(msg.sender);
        safeMint(msg.sender, reward);
        return true;
    }

    function modifyTokenBuyPrice(uint _tokenToWeiRate) public onlyOwner returns(bool){
        tokenToWeiRate = _tokenToWeiRate;
        return true;
    }

    // INTERNAL UTILITY FUNCTIONS
    function safeMint(address _receiver, uint _amount) internal returns(bool){
        _mint(_receiver, _amount);
        return true;
    }

    function _calcTokensBought(uint _msgValue) internal view returns(uint tokenAmount){
        require(_msgValue >= tokenToWeiRate, "Insufficient ETH to buy tokens");
        tokenAmount = _msgValue + tokenToWeiRate;
        return tokenAmount;
    }

    function _calcReward(address _addr) internal view returns(uint rewardAmount){
        rewardAmount = (_staked[_addr] * rewardPct)/100;
        return rewardAmount;
    }


}

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
        ERC20("TokenSTaking", "STK")
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

    function stakeToken(uint256 _amtToStake)
        public
        hasSufficientBalance(msg.sender, _amtToStake)
        returns (bool, uint256 rewardTime)
    {
        _rewardDueDate[msg.sender] = block.timestamp + minStakePeriod;
        _staked[msg.sender] += _amtToStake;

        rewardTime = _rewardDueDate[msg.sender];
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
        tokenAmount = _msgValue / tokenToWeiRate;
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

    // OPENZEPPELIN OVERRIDES
    function decimals() public pure override returns (uint8 _decimals) {
        _decimals = 5;
        return _decimals;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override hasSufficientBalance(from, amount) {
        super._transfer(from, to, amount);
    }

    /**
     * @dev fallback function ***DO NOT OVERRIDE***
     */
    fallback() external payable {
        buyTokens(msg.sender, msg.value);
    }

    /**
     * @dev low level token purchase ***DO NOT OVERRIDE***
     * @param _beneficiary Address performing the token purchase
     */
    function buyTokens(address _beneficiary, uint256 weiAmount) public payable {
        weiAmount = msg.value;
        _preValidatePurchase(_beneficiary, weiAmount);

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);

        // update state
        tokenToWeiRate = tokenToWeiRate.add(weiAmount);

        _processPurchase(_beneficiary, tokens);
        emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);

        _updatePurchasingState(_beneficiary, weiAmount);

        _forwardFunds();
        _postValidatePurchase(_beneficiary, weiAmount);
    }

    /**
     * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.
     * @param _beneficiary Address performing the token purchase
     * @param _weiAmount Value in wei involved in the purchase
     */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount)
        internal
        pure
    {
        require(_beneficiary != address(0));
        require(_weiAmount != 0);
    }

    /**
     * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
     * @param _beneficiary Address performing the token purchase
     * @param _weiAmount Value in wei involved in the purchase
     */
    function _postValidatePurchase(address _beneficiary, uint256 _weiAmount)
        internal
    {
        // optional override
    }

    /**
     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
     * @param _beneficiary Address performing the token purchase
     * @param _tokenAmount Number of tokens to be emitted
     */
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount)
        internal
    {
        token.transfer(_beneficiary, _tokenAmount);
    }

    /**
     * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
     * @param _beneficiary Address receiving the tokens
     * @param _tokenAmount Number of tokens to be purchased
     */
    function _processPurchase(address _beneficiary, uint256 _tokenAmount)
        internal
    {
        _deliverTokens(_beneficiary, _tokenAmount);
    }

    /**
     * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
     * @param _beneficiary Address receiving the tokens
     * @param _weiAmount Value in wei involved in the purchase
     */
    function _updatePurchasingState(address _beneficiary, uint256 _weiAmount)
        internal
    {
        // optional override
    }

    /**
     * @dev Override to extend the way in which ether is converted to tokens.
     * @param _weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint256 _weiAmount)
        internal
        view
        returns (uint256)
    {
        return _weiAmount.mul(tokenToWeiRate);
    }

    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds() internal {
        payable(owner).transfer(msg.value);
    }
}
