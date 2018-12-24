pragma solidity 0.4.25;

contract OraclizeService {

    address authorized = 0xefd8eD39D00D98bf43787ad0cef9afee2B5DB34F;
    modifier onlyAuthorized() {
        require(msg.sender == authorized);
        _;
    }

    QueryData[] queries;
    struct QueryData {
        bytes currency;
        function(uint, bytes memory)
            external
            returns (bool) callbackFunction;
    }

    event NewRequestEvent(uint requestID);

    function query(
        bytes _currency,
        function(uint, bytes memory) external returns(bool) _callbackFn
    ) public {
        //Registering callback
        queries.push(QueryData(_currency, _callbackFn));
        emit NewRequestEvent(queries.length - 1);
    }

    function reply(uint requestID, bytes response) public onlyAuthorized {
        require(queries[requestID].callbackFunction(requestID, response));
        delete queries[requestID]; //release storage
    }
}

contract OracleUser {
    modifier onlyOracle {
        require(msg.sender == address(oraclizeService),
            "Only oracle can call this.");
        _;
    }
    // known contract address of Oraclize Service
    OraclizeService constant oraclizeService =
        OraclizeService(0x611B947ec990Ba4e1655BF1A37586467144A2D65);
    event ResponseReceived(uint requestID, bytes response);

    function getUSDRate() public {
        oraclizeService.query("USD", this.queryResponse);
    }

    function queryResponse(uint _requestID, bytes _response)
    public onlyOracle
    returns (bool) {
        // Use the response data
        //...
        emit ResponseReceived(_requestID, _response);
        return true;
    }
}