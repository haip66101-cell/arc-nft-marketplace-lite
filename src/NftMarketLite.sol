// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IERC721 {
    function transferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract NftMarketLite {
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

    function list(address nft, uint256 tokenId, uint256 price) external returns (uint256) {
        require(IERC721(nft).ownerOf(tokenId) == msg.sender, "NOT_NFT_OWNER");
        listings.push(Listing(msg.sender, nft, tokenId, price, true));
        emit Listed(listings.length - 1, nft, tokenId, price);
        return listings.length - 1;
    }

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

    function cancel(uint256 id) external {
        Listing storage l = listings[id];
        require(l.seller == msg.sender && l.active, "CANNOT");
        l.active = false;
        emit Cancelled(id);
    }

    function setFee(uint256 _feeBps) external onlyOwner { feeBps = _feeBps; }
}
