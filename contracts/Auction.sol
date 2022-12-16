// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

pragma solidity 0.8.17;

import "./Thor.sol";

contract Auction is Thor {
    // set User price
    mapping(address => uint256) UserPrice;
    //to store maxBidprice
    uint256 public _maxBidPrice;
    //to store maxbitPriceholder address
    address public _maxBidPriceHolder;
    //token owner set salesPrice
    uint256 salePrice;
    //To set start time
    uint256 startTime;
    //to set end Time
    uint256 endTime;
    //to set token id 
    uint256 tokenId;

    /**
     * @dev Emitted when owner set the auction 
     */
    event setAuctionDetails(
        uint256 _SalePrice,
        uint256 _StartTime,
        uint256 _EndTime,
        uint256 _tokenId
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

      // require statement for start time and end time

    modifier time() {
        require(startTime <= block.timestamp, "Sale time is not started yet");
        require(endTime >= block.timestamp, "Time up");
        _;
    }

    constructor() {}

    /*
     * @dev auction for perticular NFT
     * @param tokenId and Amount(Ether)
     */

    function auction(uint256 _tokenId) public payable time {
        require(tokenId == _tokenId, "Sale is not started for this token id");
        require(
            msg.value >= salePrice,
            "Amount should be greater than the sales price"
        );
        UserPrice[msg.sender] = msg.value;
        maxBidder(msg.value);
        emit AuctionDetails(_tokenId, msg.value);
    }

    /*
     * Internal function to set maxBitPrice and maxBitPriceHolder
     */

    function maxBidder(uint256 amount) internal {
        if (amount > _maxBidPrice) {
            _maxBidPriceHolder = msg.sender;
            _maxBidPrice = amount;
        }
    }

    /*
     * Once the sales is over, the owner send nft to maxBidPriceHolder
     * Owner can withdraw the maxBitPrice
     */

    function transferNFT() external{
        require(block.timestamp >= endTime, "sale is not completed");
        address TokenHolder = Thor.ownerOf(tokenId);
        require(TokenHolder == msg.sender, "Only token holder transfer the token");
        Thor.safeTransferFrom(TokenHolder, _maxBidPriceHolder, tokenId);
        payable(msg.sender).transfer(_maxBidPrice);
        UserPrice[_maxBidPriceHolder] = 0;
        emit TransferNFT(
            TokenHolder,
            _maxBidPriceHolder,
            tokenId
        );
    }

    receive() external payable {}

    //user can withdraw their amount

    function withDraw() external returns (bool) {
        require(
            _maxBidPriceHolder != msg.sender,
            "You cannot transfer your amount"
        );
        payable(msg.sender).transfer(UserPrice[msg.sender]);
        emit Transfer(msg.sender,  UserPrice[msg.sender]);
        return true;
    }

    /* *
     * @dev set Auction details for perticular NFT
     * @param setSalesPrice, setStartTime, setEndTime and tokenID
     */

    function setAuction(
        uint256 setSalePrice,
        uint256 setStartTime,
        uint256 setEndTime,
        uint256 _tokenId
    ) external {

        require(Thor.ownerOf(_tokenId) == msg.sender, "Only owner can set Auction");
        salePrice = setSalePrice;
        startTime = setStartTime;
        endTime = setEndTime;
        tokenId = _tokenId;

        emit setAuctionDetails(
            setSalePrice,
            setStartTime,
            setEndTime,
            _tokenId
        );
    }

    // owner can update the end time
    function updateEndTime(uint256 setEndTime) external onlyOwner {
        require(setEndTime >= block.timestamp,"Time should be greater than the current time");
        require(endTime <= setEndTime,"Time should be greater than the current end time");
        endTime = setEndTime;
    }
}
