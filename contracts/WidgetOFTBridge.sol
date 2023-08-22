// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./token/oft/v2/IOFTV2.sol";

interface IWidgetOFTBridge {
    struct FeeObj {
        uint256 tenthBps; // bps is to an extra decimal place
        address feeCollector;
    }

    event WidgetSend(address oftToken, uint256 tenthBps, uint256 widgetFee);
    
    function sendTokens(
        address oftToken,
        uint16 _dstChainId,
        bytes32 _toAddress,
        uint _amount,
        ICommonOFT.LzCallParams calldata _callParams,
        FeeObj calldata _feeObj
    ) external payable;
}


contract WidgetOFTBridge is IWidgetOFTBridge, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 public constant TENTH_BPS_DENOMINATOR = 100000;

    function  sendTokens(
        address oftToken,
        uint16 _dstChainId,
        bytes32 _toAddress,
        uint _amount,
        ICommonOFT.LzCallParams calldata _callParams,
        FeeObj calldata _feeObj
    ) public  virtual override nonReentrant payable {
        uint256 widgetFee = _getAndPayWidgetFee(oftToken, _amount, _feeObj);

        IOFTV2(oftToken).sendFrom{value: msg.value}(
            address(this),
            _dstChainId,
            _toAddress,
            _amount - widgetFee,
            _callParams
        );

        emit WidgetSend(oftToken, _feeObj.tenthBps, widgetFee);
    }

    function _getAndPayWidgetFee(
        address oftToken,
        uint256 _amount,
        FeeObj calldata _feeObj
    ) internal returns (uint256 widgetFee) {
        // move all the tokens to this contract
        IERC20(oftToken).safeTransferFrom(msg.sender, address(this), _amount);

        // calculate the widgetFee
        widgetFee = _amount * _feeObj.tenthBps / TENTH_BPS_DENOMINATOR;

        // pay the widget fee
        IERC20(oftToken).safeTransfer(_feeObj.feeCollector, widgetFee);

        return widgetFee;
    }
}