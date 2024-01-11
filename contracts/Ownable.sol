// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBigBank {
    function withdraw() external;
}

contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call");
        _;
    }

    function withdraw(address _bigBankAddr) public onlyOwner {
        IBigBank(_bigBankAddr).withdraw();
    }

    receive() payable external {
        payable(owner).transfer(address(this).balance);
    }
}