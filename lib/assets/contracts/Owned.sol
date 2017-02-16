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
