// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

pragma solidity 0.8.17;

import "./Thor.sol";

contract Auction is Thor {
    // set User price
    mapping(address => uint256) UserPrice;
    uint256 public _maxBidPrice;
    address public _maxBidPriceHolder;
    uint256 salePrice;
    uint256 startTime;
    uint256 endTime;
    uint256 tokenId;
    address TokenHolder;

    event setAuctionDetails(
        uint256 _SalePrice,
        uint256 _StartTime,
        uint256 _EndTime,
        uint256 _tokenId
    );

    event AuctionDetails(uint256 _tokenId, uint256 amount);
    event TransferNFT(
        address tokenHolder,
        address _maxBidPriceHolder,
        uint256 TokenId
    );

    // salePrice = 1000000000000000000;
    //    startTime = block.timestamp;
    //    endTime = 1671107325;
    //    TokenHolder = msg.sender;
    //    tokenId = 1;

    constructor() {}

    /*
     * @dev auction for perticular NFT
     * @param tokenId and Amount(Ether)
     */

    function auction(uint256 _tokenId) public payable time {
        require(tokenId == _tokenId, "Sale is not started");
        require(
            msg.value >= salePrice,
            "Amount should be greater than the sales price"
        );
        UserPrice[msg.sender] = msg.value;
        maxBidder(msg.value);
        emit AuctionDetails(_tokenId, msg.value);
    }

    // require statement for start time and end time

    modifier time() {
        require(startTime <= block.timestamp, "Sale time is not started yet");
        require(endTime >= block.timestamp, "Time up");
        _;
    }

    /*
     * Internal function to set maxBitPrice and maxBitPriceHolder
     */

    function maxBidder(uint256 amount) internal {
        // uint256 maxBidPrice_ = _maxBidPrice;
        if (amount > _maxBidPrice) {
            _maxBidPriceHolder = msg.sender;
            _maxBidPrice = amount;
        }
    }

    /*
     * Once the sales is over, the owner send nft to maxBidPriceHolder
     * Owner can withdraw the maxBitPrice
     */

    function transferNFT() external payable{
        require(block.timestamp >= endTime, "sale is not completed");
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

    function withDraw() external payable returns (bool) {
        require(
            _maxBidPriceHolder != msg.sender,
            "You cannot transfer your amount"
        );
        payable(msg.sender).transfer(UserPrice[msg.sender]);
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

    // owner can update the start and end time
    function updateEndTime(uint256 setEndTime) external onlyOwner time {
        endTime = setEndTime;
    }
}
