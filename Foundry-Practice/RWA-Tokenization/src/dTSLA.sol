// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";

/*
 * @title dTSLA
 * @author Rahul Dindigala
*/
contract dTSLA is ConfirmedOwner, FunctionsClient {
    using FunctionRequest for FunctionsRequest.Request;
    
    enum MintOrRedeem {
        mint,
        redeem,
    }

    struct dTslaRequest {
        uint256 amountOfToken;
        address requester;
        MintOrRedeem mintOrRedeem;
    }

    address constant SEPOLIA_FUNCTIONS_ROUTER = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;
    bytes32 constant DON_ID = hex"66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000";
    uint64 immutable i_subId; 
    uint32 constant GAS_LIMIT = 300_000;

    string private s_mintSourceCode;

    mapping(bytes32 requestId => dTslaRequest request) private s_requestIdToRequest;
   
    // FUNCTIONS
    constructor(string memory mintSourceCode, uint64 subId) ConfirmedOwner(msg.sender) FunctionsCLient(SEPOLIA_FUNCTIONS_ROUTER) {
        s_mintSourceCode = mintSourceCode;
        i_subId = subId;
    }

    function sendMintRequest(uint256 amount) external onlyOwner returns (bytes32) {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(s_mintSourceCode);
        bytes32 requestId = _sendRequest(req.encodeCBOR(), i_subId, GAS_LIMIT, DON_ID);
        s_requestIdToRequest[requestId] = dTslaRequest(amount, msg.sender, MintOrRedeem.mint);
        return requestId;
    }
        
    function _mintFulFillrequest() inetrnal {}

    function sendRedeemRequest()
}

