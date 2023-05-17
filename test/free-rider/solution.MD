A new marketplace of Damn Valuable NFTs has been released! There’s been an initial mint of 6 NFTs, which are available for sale in the marketplace. Each one at 15 ETH.

The developers behind it have been notified the marketplace is vulnerable. All tokens can be taken. Yet they have absolutely no idea how to do it. So they’re offering a bounty of 45 ETH for whoever is willing to take the NFTs out and send them their way.

You’ve agreed to help. Although, you only have 0.1 ETH in balance. The devs just won’t reply to your messages asking for more.

If only you could get free ETH, at least for an instant.
----------------------------

There are 2 issues here:

- In the `function _buyOne`, it checks:

```solidity
uint256 priceToPay = offers[tokenId];
        if (priceToPay == 0)
            revert TokenNotOffered(tokenId);

        if (msg.value < priceToPay)
            revert InsufficientPayment();
```

But _buyOne is called in a loop.
Meaning we can buy all the nft for the price of one!

Moreover:
```solidity
_token.safeTransferFrom(_token.ownerOf(tokenId), msg.sender, tokenId);

        // pay seller using cached token
        payable(_token.ownerOf(tokenId)).sendValue(priceToPay);
```

Here the intention was to pay the seller, but as we transfer the nft, the `_token.ownerOf(tokenId)` become the buyer, so the buyer get back his funds!

To exploit these vulnerabilities, we can take an UniswapV2 flashswap to be able to buy all the nft for the price of one and get all the corresponding eth value.
Then we can send the nft to the dev, payback the "loan", and get all the remaining eth.