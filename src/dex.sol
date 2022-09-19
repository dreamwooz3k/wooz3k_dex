// SPDX-License-Identifier: UNLICENSED
// forge install OpenZeppelin/openzeppelin-contracts --no-comit
// touch remappings.txt -> @openzeppelin/=lib/openzeppelin-contracts/
pragma solidity ^0.8.13;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract dex is ERC20{

    ERC20 public tokenX;
    ERC20 public tokenY;

    uint256 public k;

    constructor(address _tokenX, address _tokenY) ERC20("LP-Token", "LP")
    {
        tokenX = ERC20(_tokenX);
        tokenY = ERC20(_tokenY);
    }
    function swap(uint256 tokenXAmount, uint256 tokenYAmount, uint256 tokenMinimumOutputAmount) external returns (uint256 outputAmount)
    {
        require((tokenXAmount==0 && tokenY.balanceOf(msg.sender)>=tokenXAmount) || (tokenYAmount==0 && tokenX.balanceOf(msg.sender)>=tokenXAmount));

        if(tokenXAmount==0)
        {
            uint256 outputAmount = tokenYAmount-(tokenYAmount/1000);
            require(outputAmount>=tokenMinimumOutputAmount, "tokenMinimumOutputAmount Value Check");
            require(tokenX.balanceOf(address(this)) >= outputAmount, "liquidity less");

            tokenY.transferFrom(msg.sender, address(this), tokenYAmount);
            tokenX.transfer(msg.sender, outputAmount);
        }
        else
        {
            uint256 outputAmount = tokenXAmount-(tokenXAmount/1000);
            require(outputAmount>=tokenMinimumOutputAmount, "tokenMinimumOutputAmount Value Check");
            require(tokenY.balanceOf(address(this)) >= outputAmount, "liquidity less");
            
            tokenX.transferFrom(msg.sender, address(this), tokenXAmount);
            tokenY.transfer(msg.sender, outputAmount);
        }
    }

    function addLiquidity(uint256 tokenXAmount, uint256 tokenYAmount, uint256 minimumLPTokenAmount) external returns (uint256 LPTokenAmount)
    {
        require(tokenX.balanceOf(msg.sender) >= tokenXAmount && tokenY.balanceOf(msg.sender) >= tokenYAmount, "Amount Value Check");

        tokenX.transferFrom(msg.sender, address(this), tokenXAmount);
        tokenY.transferFrom(msg.sender, address(this), tokenYAmount);
        if(totalSupply()==0)
        {
            k = tokenX.balanceOf(address(this)) * tokenY.balanceOf(address(this));
            LPTokenAmount = sqrt(k);
        }
        else
        {
            if(tokenXAmount >= tokenYAmount)
            {
                LPTokenAmount = (tokenYAmount*totalSupply())/(tokenY.balanceOf(address(this))-tokenYAmount);
            }
            else
            {
                LPTokenAmount = (tokenXAmount*totalSupply())/(tokenX.balanceOf(address(this))-tokenXAmount);
            }
        }
        
        require(LPTokenAmount>=minimumLPTokenAmount, "minimumLPToken less");
        _mint(msg.sender, LPTokenAmount);
    }

    function removeLiquidity(uint256 LPTokenAmount, uint256 minimumTokenXAmount, uint256 minimumTokenYAmount) external
    {
        require(balanceOf(msg.sender)>=LPTokenAmount);
        uint256 receive_tokenX=(tokenX.balanceOf(address(this))*LPTokenAmount)/totalSupply();
        uint256 receive_tokenY=(tokenY.balanceOf(address(this))*LPTokenAmount)/totalSupply();
        require(receive_tokenX>=minimumTokenXAmount && receive_tokenY>=minimumTokenYAmount, "minimumToken less");
        _burn(msg.sender, LPTokenAmount);
        tokenX.transfer(msg.sender, receive_tokenX);
        tokenY.transfer(msg.sender, receive_tokenY);
    }

    function sqrt(uint x) public pure returns (uint y) 
    {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) 
        {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}