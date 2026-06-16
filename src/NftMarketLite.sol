// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    /// @notice transferFrom - core operation
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IERC721 {
    /// @notice transferFrom - core operation
    function transferFrom(address from, address to, uint256 tokenId) external;
    /// @notice ownerOf - core operation
    function ownerOf(uint256 tokenId) external view returns (address);
}

/// @title NftMarketLite
/// @notice Core contract for NftMarketLite on Arc Network
/// @dev Built with Foundry, deployed on Arc testnet (Chain ID: 5042002)
contract NftMarketLite {
    /// @notice Contract version
    string public constant VERSION = "1.1.0";

    IERC20 public immutable usdc;
    address public owner;
    uint256 public feeBps = 250; // 2.5%

    struct Listing {
        address seller;
        address nft;
        uint256 tokenId;
        uint256 price;
        bool active;
    }
    Listing[] public listings;

    event Listed(uint256 indexed id, address nft, uint256 tokenId, uint256 price);
    event Sold(uint256 indexed id, address buyer, uint256 price);
    event Cancelled(uint256 indexed id);

    constructor(address _usdc) {
        require(_usdc != address(0), "BAD_USDC");
        usdc = IERC20(_usdc);
        owner = msg.sender;
    }

    modifier onlyOwner() { require(msg.sender == owner, "NOT_OWNER"); _; }

    /// @notice list - core operation
    function list(address nft, uint256 tokenId, uint256 price) external returns (uint256) {
        require(IERC721(nft).ownerOf(tokenId) == msg.sender, "NOT_NFT_OWNER");
        listings.push(Listing(msg.sender, nft, tokenId, price, true));
        emit Listed(listings.length - 1, nft, tokenId, price);
        return listings.length - 1;
    }

    /// @notice buy - core operation
    function buy(uint256 id) external {
        Listing storage l = listings[id];
        require(l.active, "NOT_ACTIVE");
        l.active = false;
        uint256 fee = (l.price * feeBps) / 10000;
        require(usdc.transferFrom(msg.sender, l.seller, l.price - fee), "PAY_SELLER_FAILED");
        if (fee > 0) require(usdc.transferFrom(msg.sender, owner, fee), "PAY_FEE_FAILED");
        IERC721(l.nft).transferFrom(l.seller, msg.sender, l.tokenId);
        emit Sold(id, msg.sender, l.price);
    }

    /// @notice cancel - core operation
    function cancel(uint256 id) external {
        Listing storage l = listings[id];
        require(l.seller == msg.sender && l.active, "CANNOT");
        l.active = false;
        emit Cancelled(id);
    }

    /// @notice setFee - core operation
    function setFee(uint256 _feeBps) external onlyOwner { feeBps = _feeBps; }
}
