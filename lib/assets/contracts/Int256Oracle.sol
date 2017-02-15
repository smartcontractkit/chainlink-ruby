pragma solidity ^0.4.6;

contract Owned {
  address public owner;

  event UpdatedOwner(address to, address from);

  modifier onlyOwner {
    if (msg.sender == owner) _;
  }

  function Owned() {
    owner = msg.sender;
  }

  function setOwner(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      address oldOwner = owner;
      owner = newOwner;
      UpdatedOwner(newOwner, oldOwner);
    }
  }
}

contract Int256Oracle is Owned {
  int256 public current;
  uint256 public updatedAt;
  uint256 requestCounter;

  event Updated(int256 current);

  function Int256Oracle(int256 newCurrent) {
    if (newCurrent != int256(0)) {
      current = newCurrent;
      updatedAt = block.number;
      Updated(current);
    }
  }

  function update(int256 newCurrent) onlyOwner {
    current = newCurrent;
    updatedAt = block.number;
    Updated(current);
  }
}
