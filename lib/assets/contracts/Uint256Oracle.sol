pragma solidity ^0.4.6;

import 'Owned.sol';

contract Uint256Oracle is Owned {
  uint256 public current;
  uint public updatedAt;
  uint requestCounter;

  event Updated(uint256 current);

  function Uint256Oracle(uint256 newCurrent) {
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
