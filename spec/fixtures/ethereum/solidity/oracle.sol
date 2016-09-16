contract Oracle {
  bytes32 currentValue;
  address creator;

  function Oracle() {
    creator = msg.sender;
  }

  function update(bytes32 newCurrent) {
    if (msg.sender != creator) return;
    currentValue = newCurrent;
  }

  function current() constant returns (bytes32 current) {
    return currentValue;
  }

  function () constant returns (bytes32 current) {
    return currentValue;
  }
}
