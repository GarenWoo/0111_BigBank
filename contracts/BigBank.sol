// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Bank.sol";

contract BigBank is Bank {
    uint public constant depositAmountLimit = 0.001 ether;
    error NotOwnable();
    error withdrawFail();
    error InsufficientAmount(uint value, uint limit);

    constructor(address _ownableContractAddr) Bank(_ownableContractAddr) {
        ownableContractAddr = _ownableContractAddr;
    }

    modifier OnlyOwnable() {
        if (msg.sender != ownableContractAddr) {
            revert NotOwnable();
        }
        _;
    }

    modifier AmountChecker() {
        if (msg.value <= depositAmountLimit) {
            revert InsufficientAmount(msg.value, depositAmountLimit);
        }
        _;
    }

    function deposit() public payable override AmountChecker {
        balance[msg.sender] += msg.value;
        super._handleRankWhenDeposit();
    }

    function withdraw() public override OnlyOwnable {
        (bool success, ) = payable(ownableContractAddr).call{value: address(this).balance}("");
        if (!success) {
            revert withdrawFail();
        }
    }
}
