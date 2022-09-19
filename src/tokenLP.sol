// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract TokenLP{
    mapping(address=>uint256) private balances;
    mapping(address=>mapping(address=>uint256)) private allowances;
    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimal;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor()
    {
        _name="LP-Token";
        _symbol="LP";
        _decimal=18;
    }
    

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimal;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) external returns (bool success) {
        require(balances[msg.sender] >= _value, "value exceeds balance");
        require(msg.sender != address(0), "transfer to the zero address");
        require(_to != address(0), "transfer from the zero address");

        unchecked {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
        }

        emit Transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool suceess) {
        require(msg.sender != address(0), "transfer from the zero address");
        require(_from != address(0), "transfer from the zero address");
        require(_to != address(0), "transfer to the zero address");

        uint256 currentAllowance = allowance(_from, msg.sender);
        require(currentAllowance >= _value, "insufficient allowance");
        unchecked {
            allowances[_from][msg.sender] -= _value;
        }
        require(balances[_from] >= _value, "value exceeds balance");

        unchecked {
            balances[_from] -= _value;
            balances[_to] += _value;
        }
        emit Transfer(msg.sender, _to, _value);
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(msg.sender != address(0), "transfer from the zero address");
        require(_spender != address(0), "transfer to the zero address");

        unchecked {
            allowances[msg.sender][_spender]= _value;
        }
        emit Approval(msg.sender, _spender , _value);
    }
    function allowance(address _owner, address _spender) public returns (uint256) {
        require(msg.sender != address(0), "transfer from the zero address");
        require(_owner != address(0), "trnasfer from the zero address");
        require(_spender != address(0), "transfer to the zero address");
        
        return allowances[_owner][_spender];
    }


    function _mint(address _owner, uint256 _eth) internal returns (bool success)
    {
        require(msg.sender != address(0), "transfer from the zero address");
        require(_owner != address(0), "transfer from the zero address");

        balances[_owner]+=_eth;
        _totalSupply+=_eth;
    }

    function _burn(address _owner, uint256 _eth) public returns (bool success)
    {
        require(msg.sender != address(0), "transfer from the zero address");
        require(_owner != address(0), "transfer from the zero address");
        require(balances[_owner] >= _eth, "transfer from the balances notthing");

        balances[_owner]-=_eth;
        _totalSupply-=_eth;
    }
}