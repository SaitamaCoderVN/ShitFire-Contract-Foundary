// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {IAggregator} from "@bisonai/orakl-contracts/src/v0.1/interfaces/IAggregator.sol";
import {VRFConsumerBase} from "@bisonai/orakl-contracts/src/v0.1/VRFConsumerBase.sol";
import {IVRFCoordinator} from "@bisonai/orakl-contracts/src/v0.1/interfaces/IVRFCoordinator.sol";
import {PriceConverter} from "./PriceConverter.sol";
import {Monee} from "./MoneeToken.sol";

error LuckyDraw__InsufficientAmount();
error LuckyDraw__OnlyOwnerCanWithdraw();
error LuckyDraw_RequestNotFound();

contract LuckyDraw is VRFConsumerBase {

    // VRF Coordinator
    IVRFCoordinator COORDINATOR;
    // Account ID to use for VRF requests
    uint64 private accountId;
    // Key Hash to use for VRF requests
    bytes32 public keyHash;
    // Gas limit to use for VRF requests
    uint32 public callbackGasLimit = 300_000;
    // Data feed contract for KLAY-USDT
    IAggregator private s_dataFeed;

    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 1 * 10 ** 18;
    address private immutable i_owner;
    Monee private moneeToken;
    uint256 public lastRandomValue;
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus) public s_requests;

    constructor(
        address dataFeed,
        address _coordinator,
        bytes32 _keyHash,
        uint64 _accountId
    ) VRFConsumerBase(_coordinator) {
        s_dataFeed = IAggregator(dataFeed);
        COORDINATOR = IVRFCoordinator(_coordinator);
        accountId = _accountId;
        keyHash = _keyHash;
        i_owner = msg.sender;
    }

    function draw() public payable {
        if (msg.value.getConversionRate(s_dataFeed) < MINIMUM_USD) {
            revert LuckyDraw__InsufficientAmount();
        }
        requestRandomWords();
        moneeToken.mint(msg.sender, lastRandomValue);
    }

    function suggestedAmount() public view returns (uint256) {
        uint256 currentPrice = PriceConverter.getPrice(s_dataFeed);
        uint256 amountSuggested = MINIMUM_USD / currentPrice;
        return amountSuggested;
    }

    function requestRandomWords() public returns (uint256 requestId) {
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            accountId,
            callbackGasLimit,
            1
        );
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        // requestId should be checked if it matches the expected request.
        // Generate random value between 1 and 50.
        if (s_requests[_requestId].exists != false) {
            revert LuckyDraw_RequestNotFound();
        }
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(_requestId, _randomWords);
        lastRandomValue = (_randomWords[0] % 50) + 1;
    }

    function withdraw() public {
        if (msg.sender != i_owner) {
            revert LuckyDraw__OnlyOwnerCanWithdraw();
        }
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success);
    }
}
