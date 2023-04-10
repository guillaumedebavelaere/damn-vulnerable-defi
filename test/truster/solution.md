More and more lending pools are offering flash loans. In this case, a new pool has launched that is offering flash loans of DVT tokens for free.

The pool holds 1 million DVT tokens. You have nothing.

To pass this challenge, take all tokens out of the pool. If possible, in a single transaction.

--------------------

The flashLoan method is doing an external call allowing
data to be passed and thus could be exploited.

```
File: contracts/truster/TrusterLenderPool.sol
32:         target.functionCall(data);
``

leads to Address Openzeppelin library:
```
File: openzeppelin-contracts/contracts/utils/Address.sol
128:     function functionCallWithValue(
129:         address target,
130:         bytes memory data,
131:         uint256 value,
132:         string memory errorMessage
133:     ) internal returns (bytes memory) {
134:         require(address(this).balance >= value, "Address: insufficient balance for call");
135:         (bool success, bytes memory returndata) = target.call{value: value}(data);
136:         return verifyCallResultFromTarget(target, success, returndata, errorMessage);
137:     }
```
`

We can call the flashloan with an amount of 0 to borrow (so nothing to repay) in order to exploit the external call, executing the approve methode of the token which would be called in the context of the pool, allowing our attacker to spent the amount of the pool.

see: contracts/truster/TrusterAttacker.sol


