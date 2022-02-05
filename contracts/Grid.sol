//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.0;

import "hardhat/console.sol";
import "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import "@superfluid-finance/ethereum-contracts/contracts/apps/SuperAppBase.sol";
import "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IConstantFlowAgreementV1.sol";

contract Grid is SuperAppBase {
    ISuperFluid private _host; // host
    IConstantFlowAgreementV1 private _cfa; // the stored constant flow agreement
    ISuperToken private _acceptedToken; // accepted token
    address private _receiver;

    constructor(
        ISuperFluid host,
        ICOnstantFlowAgreementV1 cfa,
        ISuperToken acceptedToken,
        address receiver
    ) {
        require(address(host) != address(0), "host is zero address");
        require(address(cfa) != address(0), "cfa is zero address");
        require(
            address(acceptedToken) != address(0),
            "acceptedToken is zero address"
        );
        require(address(receiver) != address(0), "receiver is zero address");
        require(!host.isApp(ISuperApp(receiver)), "receiver is an app");

        _host = host;
        _cfa = cfa;
        _acceptedToken = acceptedToken;
        _receiver = receiver;

        uint configWord = SuperAppDefinitions.APP_LEVEL_FINAL |
            SuperAppDefinitions.BEFORE_AGREEMENT_CREATED_NOOP |
            SuperAppDefinitions.BEFORE_AGREEMENT_UPDATED_NOOP |
            SuperAppDefinitions.BEFORE_AGREEMENT_TERMINATED_NOOP;
        
        _host.registerApp(configWord);
    }
    
    /**************************************************************************
     * SuperApp callbacks
     *************************************************************************/
    
    function afterAgreementCreate(
        ISuperToken _superToken,
        address _agreementClass,
        bytes32, // _agreementId,
        bytes calldata, /*_agreementData*/
        bytes calldata, // _cbdata,
        bytes calldata _ctx
    )
        external
        overrideonlyExpected(_superToken, _agreementClass)
        onlyHost
        returns (bytes memory newCtx)
    {
        return _updateOutflow(_ctx); // I think my logic goes here
    }
}
