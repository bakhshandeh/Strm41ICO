pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol';
import 'zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';

contract Strm41ICO is StandardToken {
    using SafeMath for uint256;

    string public name = "Strm41";
    string public symbol = "Strm41";
    uint256 public decimals = 18;

    uint256 public totalSupply = 10*1000000 * (uint256(10) ** decimals);
    uint256 public totalRaised; // total ether raised (in wei)

    uint256 public startTimestamp; // timestamp after which ICO will start
    uint256 public durationSeconds = 2 * 30 * 24 * 60 * 60; // 2 months

    uint256 public maxCap = 50000 * (uint256(10) ** decimals); // the ICO ether max cap (in wei)

    uint256 public minAmount = 10 * (uint256(10) ** decimals); // Minimum Transaction Amount(0.1 ETH)

    uint256 public coinsPerETH = 100;

    /**
     * Address which will receive raised funds 
     * and owns the total supply of tokens
     */
    address public fundsWallet;

    function Strm41ICO() {
        fundsWallet = 0x00F854d85e84e55bd9cb65413605E5AEc49a9990;
        startTimestamp = 1520535600;

        //initially assign all tokens to the fundsWallet
        balances[fundsWallet] = totalSupply;
        Transfer(0x0, fundsWallet, totalSupply);
    }

    //function Strm41ICO() {
    //    fundsWallet = 0x7Bd1EBD3267e8cda6d44d619ec24a1E782fB0BD5;
    //    startTimestamp = now;
    //
    //    // initially assign all tokens to the fundsWallet
    //    balances[fundsWallet] = totalSupply;
    //    Transfer(0x0, fundsWallet, totalSupply);
    //}

    function() isIcoOpen checkMin payable{
        totalRaised = totalRaised.add(msg.value);

        uint256 tokenAmount = calculateTokenAmount(msg.value);
        balances[fundsWallet] = balances[fundsWallet].sub(tokenAmount);
        balances[msg.sender] = balances[msg.sender].add(tokenAmount);

        Transfer(fundsWallet, msg.sender, tokenAmount);

        // immediately transfer ether to fundsWallet
        fundsWallet.transfer(msg.value);
    }

    function calculateTokenAmount(uint256 weiAmount) constant returns(uint256) {
        uint256 tokenAmount = weiAmount.mul(coinsPerETH);
        if (now <= startTimestamp + 7 days) {
            // +12% bonus during first week
            return tokenAmount.mul(120).div(100);
        } else if(now <= startTimestamp + 14 days){
            // +10% bonus during first week
            return tokenAmount.mul(110).div(100);
        }else if(now <= startTimestamp + 21 days){
            // +7% bonus during first week
            return tokenAmount.mul(105).div(100);
        }else{
            return tokenAmount;
        }
    }

    function transfer(address _to, uint _value) isIcoFinished returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) isIcoFinished returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    modifier isIcoOpen() {
        require(now >= startTimestamp);
        require(now <= (startTimestamp + durationSeconds));
        require(totalRaised <= maxCap);
        _;
    }

    modifier isIcoFinished() {
        require(now >= startTimestamp);
        require(totalRaised >= maxCap || (now >= (startTimestamp + durationSeconds)));
        _;
    }

    modifier checkMin(){
        require(msg.value.mul(coinsPerETH) >= minAmount);
        _;
    }

    modifier isOwner(){
        require(msg.sender == fundsWallet);
        _;
    }
}
