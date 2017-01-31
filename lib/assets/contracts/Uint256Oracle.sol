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

contract Uint256Oracle is Owned {
  uint256 public current;
  uint public updatedAt;
  uint requestCounter;

  event Updated(uint256 current);

  function Bytes32Oracle(uint256 newCurrent) {
    if (newCurrent != uint256(0)) {
      current = newCurrent;
      updatedAt = block.number;
      Updated(current);
    }
  }

  function update(uint256 newCurrent) onlyOwner {
    current = newCurrent;
    updatedAt = block.number;
    Updated(current);
  }
}
