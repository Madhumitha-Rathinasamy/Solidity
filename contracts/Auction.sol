// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

pragma solidity 0.8.17;

import "openzeppelin-solidity/contracts/token/ERC721/IERC721.sol";
import "openzeppelin-solidity/contracts/security/Pausable.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";

contract Auction is Ownable, Pausable {
    struct TokenDetails {
        IERC721 token;
        uint256 tokenId;
        uint256 salePrice;
        uint256 startTime;
        uint256 endTime;
    }
    TokenDetails[] public tokenInfo;

    // set User price
    mapping(uint256 => mapping(address => uint256)) public UserPrice;
    //to store maxBidprice
    uint256 public _maxBidPrice;
    //to store maxbitPriceholder address
    address public _maxBidPriceHolder;

    /**
     * @dev Emitted when owner set the auction
     */
    event setAuctionDetails(
        uint256 _SalePrice,
        uint256 _StartTime,
        uint256 _EndTime,
        uint256 _tokenId,
        uint256 auctionId
    );

    /**
     * @dev Emitted when user transfer their balances from the contract.
     */

    event Transfer(address account, uint256 amount);

    /**
     * @dev Emitted when user involve in auction
     */

    event AuctionDetails(uint256 _tokenId, uint256 amount);

    /**
     * @dev Emitted when owner withdraw the balances of maxBidPriceHoldder
     */
    event TransferNFT(
        address tokenHolder,
        address _maxBidPriceHolder,
        uint256 TokenId
    );

    constructor() {}

    /*
     * @dev auction for perticular NFT
     * @param tokenId and Amount(Ether)
     */

    function auction(uint256 auctionId) public payable {
        require(
            tokenInfo[auctionId].startTime <= block.timestamp,
            "Sale time is not started yet"
        );
        require(tokenInfo[auctionId].endTime >= block.timestamp, "Time up");
        require(
            tokenInfo.length > auctionId,
            "Sale is not started for this token id"
        );
        require(
            msg.value >= tokenInfo[auctionId].salePrice,
            "Amount should be greater than the sales price"
        );
        UserPrice[auctionId][msg.sender] = msg.value;
        maxBidder(msg.value);
        emit AuctionDetails(auctionId, msg.value);
    }

    /*
     * Internal function to set maxBitPrice and maxBitPriceHolder
     */

    function maxBidder(uint256 amount) internal {
        require(
            amount > _maxBidPrice,
            "Bidder Amount is greater than the given amount"
        );
        _maxBidPriceHolder = msg.sender;
        _maxBidPrice = amount;
    }

    /*
     * Once the sales is over, the owner send nft to maxBidPriceHolder
     * Owner can withdraw the maxBitPrice
     */

    function transferNFT(uint256 auctionId) external {
        require(
            block.timestamp >= tokenInfo[auctionId].endTime,
            "sale is not completed"
        );
        IERC721 tokenAddress = tokenInfo[auctionId].token;
        address tokenHolder = tokenAddress.ownerOf(
            tokenInfo[auctionId].tokenId
        );
        require(
            tokenHolder == msg.sender,
            "Only token holder transfer the token"
        );
        tokenAddress.safeTransferFrom(
            tokenHolder,
            _maxBidPriceHolder,
            tokenInfo[auctionId].tokenId
        );

        payable(msg.sender).transfer(_maxBidPrice);
        UserPrice[auctionId][_maxBidPriceHolder] = 0;
        emit TransferNFT(
            tokenHolder,
            _maxBidPriceHolder,
            tokenInfo[auctionId].tokenId
        );
    }

    receive() external payable {}

    //user can withdraw their amount

    function withDraw(uint256 auctionId) external {
        require(
            _maxBidPriceHolder != msg.sender,
            "You cannot transfer your amount"
        );
        payable(msg.sender).transfer(UserPrice[auctionId][msg.sender]);
        emit Transfer(msg.sender, UserPrice[auctionId][msg.sender]);
    }

    /* *
     * @dev set Auction details for perticular NFT
     * @param setSalesPrice, setStartTime, setEndTime and tokenID
     */

    function setAuction(
        uint256 setSalePrice,
        uint256 setStartTime,
        uint256 setEndTime,
        uint256 _tokenId,
        IERC721 tokenAddress
    ) external {
        tokenInfo.push(
            TokenDetails({
                token: tokenAddress,
                salePrice: setSalePrice,
                startTime: setStartTime,
                endTime: setEndTime,
                tokenId: _tokenId
            })
        );
        uint256 auctionId = tokenInfo.length - 1;
        IERC721 _tokenAddress = tokenInfo[auctionId].token;
        require(
            _tokenAddress.ownerOf(_tokenId) == msg.sender,
            "Only owner can set Auction"
        );

        emit setAuctionDetails(
            setSalePrice,
            setStartTime,
            setEndTime,
            _tokenId,
            auctionId
        );
    }

    // owner can update the end time
    function updateEndTime(uint256 auctionId, uint256 setEndTime) external {
        require(auctionId <= tokenInfo.length - 1, "check Auction id");
        IERC721 _tokenAddress = tokenInfo[auctionId].token;
        require(
            _tokenAddress.ownerOf(tokenInfo[auctionId].tokenId) == msg.sender,
            "Only owner can change the end time"
        );
        require(
            setEndTime >= block.timestamp,
            "Time should be greater than the current time"
        );
        require(
            tokenInfo[auctionId].endTime <= setEndTime,
            "Time should be greater than the current end time"
        );
        tokenInfo[auctionId].endTime = setEndTime;
    }
}
