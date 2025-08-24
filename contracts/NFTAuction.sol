// SPDX-License-Identifier:  MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract NFTAuction is Initializable {
    struct Auction {
        //卖家
        address seller;
        //拍卖持续时间
        uint256 duration;
        //开始时间
        uint256 startTime;
        //起始价格
        uint256 startPrice;
        //是否结束
        bool ended;
        //最高出价者
        address highestBidder;
        //最高价格
        uint256 highestBid;
        //nft合约地址
        address nftAddress;
        //tokenId
        uint256 tokenId;
    }

    //状态变量
    mapping(uint256 => Auction) public auctions;
    //下一个拍卖ID
    uint256 public nextAuctionId;
    //管理员地址
    address public admin;

    function initialize() public initializer {
        admin = msg.sender;
    }

    function createAuction(
        uint _duration,
        uint256 _startPrice,
        address contractAddr,
        uint256 tokenId
    ) public {
        auctions[nextAuctionId] = Auction({
            seller: msg.sender,
            duration: _duration,
            startTime: block.timestamp,
            startPrice: _startPrice,
            ended: false,
            highestBidder: address(0),
            highestBid: 0,
            nftAddress: contractAddr,
            tokenId: tokenId
        });
        nextAuctionId++;
    }

    function placeBid(uint256 _auctionId) public payable {
        Auction storage auction = auctions[_auctionId];
        require(!auction.ended, "Auction has ended");
        require(
            msg.value > auction.highestBid && msg.value >= auction.startPrice,
            "Bid must be higher than current highest bid and start price"
        );

        // 如果有出价者，退还之前的出价
        if (auction.highestBidder != address(0)) {
            payable(auction.highestBidder).transfer(auction.highestBid);
        }

        auction.highestBidder = msg.sender;
        auction.highestBid = msg.value;
    }

    function endAuction(uint256 _auctionId) public {
        Auction storage auction = auctions[_auctionId];
        require(!auction.ended, "Auction already ended");
        require(
            block.timestamp >= auction.startTime + auction.duration,
            "Auction is still ongoing"
        );

        auction.ended = true;

        // 将拍卖所得转给卖家
        payable(auction.seller).transfer(auction.highestBid);
    }
}
