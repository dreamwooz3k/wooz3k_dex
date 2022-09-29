// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";

contract Dex is ERC20 {
    using SafeERC20 for IERC20;

    IERC20 _tokenX;
    IERC20 _tokenY; 

    uint256 private k;

    constructor(address tokenX, address tokenY) ERC20("DreamAcademy DEX LP token", "DA-DEX-LP") {
        require(tokenX != tokenY, "DA-DEX: Tokens should be different");

        _tokenX = IERC20(tokenX);
        _tokenY = IERC20(tokenY);
    }

    function swap(uint256 tokenXAmount, uint256 tokenYAmount, uint256 tokenMinimumOutputAmount)
        external
        returns (uint256 outputAmount)
    {
        require(tokenXAmount % 1000 == 0 && tokenYAmount % 1000 ==0, "no fee");
        require((tokenXAmount==0 && _tokenY.balanceOf(msg.sender)>=tokenXAmount) || (tokenYAmount==0 && _tokenX.balanceOf(msg.sender)>=tokenXAmount));

        if(tokenXAmount==0)
        {
            uint256 input = tokenYAmount-(tokenYAmount/1000);
            uint256 k_div = _tokenY.balanceOf(address(this)) + input;
            outputAmount = _tokenX.balanceOf(address(this)) - k/k_div;
            require(outputAmount>=tokenMinimumOutputAmount, "tokenMinimumOutputAmount Value Check");
            require(_tokenX.balanceOf(address(this)) >= outputAmount, "liquidity less");

            _tokenY.transferFrom(msg.sender, address(this), tokenYAmount);
            _tokenX.transfer(msg.sender, outputAmount);
        }
        else
        {
            uint256 input = tokenXAmount-(tokenXAmount/1000);
            uint256 k_div = _tokenX.balanceOf(address(this)) + input;
            outputAmount = _tokenY.balanceOf(address(this)) - k/k_div;
            require(outputAmount>=tokenMinimumOutputAmount, "tokenMinimumOutputAmount Value Check");
            require(_tokenY.balanceOf(address(this)) >= outputAmount, "liquidity less");
            
            _tokenX.transferFrom(msg.sender, address(this), tokenXAmount);
            _tokenY.transfer(msg.sender, outputAmount);
        }

        k = _tokenX.balanceOf(address(this))*_tokenY.balanceOf(address(this));
    }

    function addLiquidity(uint256 tokenXAmount, uint256 tokenYAmount, uint256 minimumLPTokenAmount)
        external
        returns (uint256 LPTokenAmount)
    {
        require(tokenXAmount != 0 && tokenYAmount !=0, "AddLiquidity invalid initialization check error");
        require(_tokenX.allowance(msg.sender, address(this)) >= tokenXAmount && _tokenY.allowance(msg.sender, address(this)) >= tokenYAmount, "ERC20: insufficient allowance");
        require(_tokenX.balanceOf(msg.sender) >= tokenXAmount && _tokenY.balanceOf(msg.sender) >= tokenYAmount, "ERC20: transfer amount exceeds balance");

        _tokenX.transferFrom(msg.sender, address(this), tokenXAmount);
        _tokenY.transferFrom(msg.sender, address(this), tokenYAmount);

        k=_tokenX.balanceOf(address(this))*_tokenY.balanceOf(address(this));

        if(totalSupply()==0)
        {
            LPTokenAmount = _tokenX.balanceOf(address(this)) * _tokenY.balanceOf(address(this));
            LPTokenAmount = sqrt(LPTokenAmount);
        }
        else
        {
            uint LPTokenAmountX=(tokenYAmount*totalSupply())/(_tokenY.balanceOf(address(this))-tokenYAmount);
            uint LPTokenAmountY=(tokenXAmount*totalSupply())/(_tokenX.balanceOf(address(this))-tokenXAmount);

            if(LPTokenAmountX >= LPTokenAmountY)
            {
                LPTokenAmount = LPTokenAmountY;
            }
            else
            {
                LPTokenAmount = LPTokenAmountX;
            }
        }
        
        require(LPTokenAmount>=minimumLPTokenAmount, "minimumLPToken less");
        _mint(msg.sender, LPTokenAmount);
    }

    function removeLiquidity(uint256 LPTokenAmount, uint256 minimumTokenXAmount, uint256 minimumTokenYAmount)
        external returns (uint256 transferX, uint256 transferY)
    {
        require(balanceOf(msg.sender)>=LPTokenAmount);
        transferX=(_tokenX.balanceOf(address(this))*LPTokenAmount)/totalSupply();
        transferY=(_tokenY.balanceOf(address(this))*LPTokenAmount)/totalSupply();
        require(transferX>=minimumTokenXAmount && transferY>=minimumTokenYAmount, "minimumToken less");
        _burn(msg.sender, LPTokenAmount);
        _tokenX.transfer(msg.sender, transferX);
        _tokenY.transfer(msg.sender, transferY);

        k = (_tokenX.balanceOf(address(this))) * _tokenY.balanceOf(address(this));
    }

    // From UniSwap core
    function sqrt(uint256 y) private pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
