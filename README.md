# 练习题（01.10）

### Ownable 合约

**Ownable 合约已部署至：**
https://goerli.etherscan.io/address/0x0047FBe927f2c593346836Ff42af3aa1bdB1e920#code

```solidity
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
```

### Bank 合约（abstract，被 BigBank 合约继承）

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Bank {
    // To protect personal privacy, some of the variables are set internal.
    // To get those values of variables, set getter-functions to get users' values by their own instead of being queried by anyone.
    mapping(address => uint) internal balance;
    address[3] internal rank;
    address internal ownableContractAddr;
    error doNotTransferETHDirectly();

    constructor(address _ownableContractAddr) {
        ownableContractAddr = _ownableContractAddr;
    }

    function deposit() public virtual payable {
        balance[msg.sender] += msg.value;
        _handleRankWhenDeposit();
    }

    receive() external payable {
        revert doNotTransferETHDirectly();
    }

    function withdraw() public virtual {
        payable(ownableContractAddr).transfer(address(this).balance);
    }

    function getBalance(address _account) public view returns (uint) {
        return balance[_account];
    }

    function getTopThreeAccount()
        public
        view
        returns (address, address, address)
    {
        return (rank[0], rank[1], rank[2]);
    }

    function _handleRankWhenDeposit() internal {
        uint membershipIndex = _checkRankMembership();
        uint convertedIndex;
        uint indexRecord = 777;
        if (membershipIndex != 999) {
            // Case 1: msg.sender is already inside the top3 rank.
            convertedIndex = membershipIndex + 4;
            for (uint i = convertedIndex - 3; i > 1; i--) {
                if (membershipIndex != 0) {
                    if (balance[msg.sender] > balance[rank[i - 2]]) {
                        indexRecord = i - 2;
                        for (uint j = 2; j > i - 2; j--) {
                            rank[j] = rank[j - 1];
                        }
                        // Boundry condition
                        if (indexRecord == 0) {
                            rank[indexRecord] = msg.sender;
                        }
                    } else {
                        if (indexRecord != 777) {
                            rank[indexRecord] = msg.sender;
                        }
                    }
                }
            }
        } else {
            // Case 2: msg.sender is not inside the top3 rank.
            for (uint i = 3; i > 0; i--) {
                if (balance[msg.sender] > balance[rank[i - 1]]) {
                    indexRecord = i - 1;
                    // move backward the element(s) which is(/are) right at the index and also behind the index
                    for (uint j = 2; j > i - 1; j--) {
                        rank[j] = rank[j - 1];
                    }
                    // Boundry condition
                    if (indexRecord == 0) {
                        rank[indexRecord] = msg.sender;
                    }
                } else {
                    if (indexRecord != 777) {
                        rank[indexRecord] = msg.sender;
                    }
                }
            }
        }
    }

    function _checkRankMembership() internal view returns (uint) {
        uint index = 999;
        for (uint i = 0; i < 3; i++) {
            if (rank[i] == msg.sender) {
                index = i;
                break;
            }
        }
        return index;
    }
}
```

### BigBank 合约

**BigBank合约已部署至：**
https://goerli.etherscan.io/address/0x22975Bc9Fe0423A7C277988EDE2567c9698958Ac#code

```solidity
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
```

