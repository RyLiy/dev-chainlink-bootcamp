pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
contract PriceExercise is ChainlinkClient{

    address private oracle;
    bytes32 private jobId;
    uint256 private fee;
    AggregatorV3Interface internal priceFeed;

bool public priceFeedGreater;
constructor(address _oracle, string memory _jobId, uint256 _fee, address _link, address AggregatorAddress) public {
priceFeed = AggregatorV3Interface(AggregatorAddress);

}

    function getLatestPrice() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }

    function fulfill(bytes32 _requestId, int256 _price) public recordChainlinkFulfillment(_requestId)
    {
        int256 storedPrice = _price;

        if (getLatestPrice() > storedPrice) {
            priceFeedGreater = true;
        } else{
            priceFeedGreater = false;
        }
    }

    function requestPriceData() public returns (bytes32 requestID)
    {
       Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector); 
    request.add("get", "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BTC&tsyms=USD");
    request.add("path", "RAW.BTC.USD.PRICE");
        
    // Multiply the result by 1000000000000000000 to remove decimals
    int timesAmount = 10**18;
    request.addInt("times", timesAmount);
        
    // Sends the request
    return sendChainlinkRequestTo(oracle, request, fee);
    }
}
