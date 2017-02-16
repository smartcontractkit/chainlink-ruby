pragma solidity ^0.4.6;

import 'Owned.sol';

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
