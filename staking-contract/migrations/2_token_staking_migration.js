// Basic Staking contract deployment process
const TokenStaking = artifacts.require("TokenStaking");

const minStakePeriod = 7; // days
const tokenToWeiRate = 10000000000;

module.exports = function(deployer, network, accounts) {
    deployer.deploy(TokenStaking, minStakePeriod, tokenToWeiRate, { from: accounts[0] });
};