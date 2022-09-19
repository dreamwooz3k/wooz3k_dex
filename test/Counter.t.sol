// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/dex.sol";
import "../src/erc20mint.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CounterTest is Test{
    dex public wooz3k;
    erc20mint public tokenX;
    erc20mint public tokenY;

    address public a;
    address public b;
    address public c;
    address public d;

    function setUp() public 
    {
        tokenX = new erc20mint("tokenX", "X");
        tokenY = new erc20mint("tokenY", "Y");
        wooz3k = new dex(address(tokenX), address(tokenY));

        a=address(1);

        tokenX.mint(a,100 ether);
        tokenY.mint(a,100 ether);
    }

    function test_addLiquidity() public 
    {
        vm.startPrank(a);
        tokenX.approve(address(wooz3k), 100 ether);
        tokenY.approve(address(wooz3k), 100 ether);
        wooz3k.addLiquidity(10 ether, 10 ether, 10 ether);
        wooz3k.addLiquidity(2 ether, 8 ether, 2 ether);
        //assert(tokenX.balanceOf(a)==100 ether && tokenY.balanceOf(a)==100 ether);
        assert(wooz3k.balanceOf(a) == 12 ether);
    }

    function test_swap() public
    {
        test_addLiquidity();
        tokenX.balanceOf(address(wooz3k));
        wooz3k.swap(1 ether, 0, 0);
        assert(tokenX.balanceOf(address(wooz3k))==13000000000000000000);
        assert(tokenY.balanceOf(address(wooz3k))==17001000000000000000);
        wooz3k.totalSupply();
        wooz3k.removeLiquidity(12000000000000000000, 13000000000000000000, 17001000000000000000);
        wooz3k.totalSupply();
        tokenX.balanceOf(address(wooz3k));
        tokenY.balanceOf(address(wooz3k));
    }

}