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

contract Oracle is Owned {
  bytes32 public current;
  uint public updatedAt;
  uint requestCounter;

  event Updated(bytes32 current);

  function Oracle(bytes32 newCurrent) {
    if (newCurrent != bytes32(0)) {
      current = newCurrent;
      updatedAt = block.number;
      Updated(current);
    }
  }

  function update(bytes32 newCurrent) onlyOwner {
    current = newCurrent;
    updatedAt = block.number;
    Updated(current);
  }
}
