// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20Ext is ERC20,Ownable{
    //支持增发，支持销毁，交易收取手续费，交易部分销毁
    using SafeMath for uint256;

    uint public feeRatio;//手续费千分比：feeRatio/1000
    uint public burnRatio;//销毁千分比：burnRatio/1000
    address public feeAddress;//手续费配置地址

    constructor () ERC20('THIS IS A EXTEND TOKEN','ADT'){
    }

    function set(uint _feeRatio,uint _burnRatio,address _feeAddress) public onlyOwner{
        feeRatio = _feeRatio;
        burnRatio = _burnRatio;
        feeAddress = _feeAddress;
    }

    function mint(address _account,uint256 _amount) public onlyOwner{
        _mint(_account,_amount);
    }

    function burn(uint256 _amount) public{
        require(balanceOf(msg.sender) >= _amount,"burn amount exceeds balance");
        _burn(msg.sender,_amount);
    }

    function transfer(address _to, uint256 _amount) public virtual override returns (bool) {
        require(balanceOf(msg.sender) >= _amount, "transfer amount exceeds balance");
        require(feeAddress != address(0), "feeAddress not seted");
        require(feeRatio > 0, "fee not seted");
        uint256 fee = _amount.mul(feeRatio).div(1000);
        uint256 burnAmount = _amount.mul(burnRatio).div(1000);
        uint256 amount = _amount.sub(fee).sub(burnAmount);
        _transfer(msg.sender, _to, amount);
        _transfer(msg.sender, feeAddress, fee);
        if(burnAmount > 0){
            _burn(msg.sender,burnAmount);
        }
        return true;
    }
}