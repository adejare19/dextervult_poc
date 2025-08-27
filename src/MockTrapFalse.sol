pragma solidity ^0.8.20;
import "./SafeWallet.sol";

contract MockTrapFalse is IDroseraTrap {
    function collect() external pure override returns (bytes memory) { return ""; }
    function shouldRespond(bytes[] calldata) external pure override returns (bool, bytes memory) {
        return (false, bytes(""));
    }
}