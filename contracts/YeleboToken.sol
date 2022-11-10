//SPDX-License-Identifier:MIT
pragma solidity >=0.4.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract YeleboToken is ERC20 {
    constructor() ERC20("YELEBOToken","YELEBO"){
        _mint(msg.sender,2000*10**18);
    }
    function mint(address _to,uint _amount) public returns(uint){
        _mint(_to,_amount);
        return _amount;
    }
}