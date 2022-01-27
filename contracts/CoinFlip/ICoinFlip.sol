//SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./structs/Game.sol";
pragma solidity ^0.8.0;

interface ICoinFlip {
    enum STATUS {created, pendingflip, pendingVrfBlock, pendingsettlement, settled}

    function _fee() external view returns(uint);

    function _token() external view returns(IERC20);

    function _vrfDelay() external view returns(uint);

    function status(uint gameId) external view returns(STATUS);

    function getGame(uint gameId) external view returns(Game memory);

    function getGames(uint[] memory gameIds) external view returns(Game[] memory);

    function getGamesLength() external view returns(uint);

    function setToken(IERC20 token) external;

    function setFee(uint fee) external;

    function setVrfDelay(uint vrfDelay) external;

    function createGame(string memory name, uint price) external ;

    function joinGame(uint gameId) external;

    function flip(uint gameId) external;

    function settle(uint gameId) external;

    function retrieveTokens(uint amount) external;

}