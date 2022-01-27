//SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/access/Ownable.sol";
import "miscsolidity/contracts/fee/FeeTakersERC20.sol";
import "../utils/Vrf.sol";
import "./ICoinFlip.sol";
pragma solidity ^0.8.0;

contract CoinFlip is ICoinFlip, Ownable, Vrf, FeeTakersERC20 {
    constructor(IERC20 token, uint fee, uint vrfDelay) {
        setFee(fee);
        setToken(token);
        setVrfDelay(vrfDelay);
    }

    uint public override _fee;
    IERC20 public override _token;
    uint public override _vrfDelay;

    function status(uint gameId) public override view returns(STATUS) {
        Game storage game = _games[gameId];
        return _getStatus(game);
    }

    function getGame(uint gameId) public override view returns(Game memory) {
        return _games[gameId];
    }

    function getGames(uint[] memory gameIds) public override view returns(Game[] memory games) {
        games = new Game[](gameIds.length);
        for(uint i; i < gameIds.length; i ++) {
            games[i] = _games[gameIds[i]];
        }
    }

    function getGamesLength() public override view returns(uint) {
        return _games.length;
    }

    Game[] _games;

    function setToken(IERC20 token) public override onlyOwner {
        _token = token;
    }

    function setFee(uint fee) public override onlyOwner {
        _fee = fee;
    }

    function setVrfDelay(uint vrfDelay) public override onlyOwner {
        _vrfDelay = vrfDelay;
    }

    function createGame(string memory name, uint price) public override {
        _games.push(
            Game(
                name,
                price,
                msg.sender,
                address(0),
                address(0),
                0
            )
        );
        _token.transferFrom(msg.sender, address(this), price);
    }

    function joinGame(uint gameId) public override {
        Game storage game = _games[gameId];

        require(_getStatus(game) == STATUS.created, "Game already full.");

        game.player2 = msg.sender;

        _token.transferFrom(msg.sender, address(this), game.price);
    }

    function flip(uint gameId) public override {
        Game storage game = _games[gameId];

        require(_getStatus(game) == STATUS.pendingflip, "Game not ready to flip yet.");
        require(msg.sender == game.player1, "You are not player 1.");

        game.vrfBlock = block.number + _vrfDelay;
    }

    function settle(uint gameId) public override {
        Game storage game = _games[gameId];

        require(_getStatus(game) == STATUS.pendingsettlement, "Game not ready to settle yet.");
        require(msg.sender == game.player1 || msg.sender == game.player2, "You aren't part of this flip.");

        bytes32 randomHash = _vrf(game.vrfBlock);

        bool player1Wins = uint(randomHash) % 2 < 1;

        if(player1Wins) {
            game.winner = game.player1;
        } else {
            game.winner = game.player2;
        }

        uint toWinner = game.price * 2;
        uint fee = _calculateFee(toWinner);
        toWinner -= fee;

        _token.transfer(game.winner, toWinner);

        _distributeFeeERC20(_token, fee);
    }

    
    function _getStatus(Game storage game) private view returns(STATUS) {
        if(game.winner != address(0)) {
            return STATUS.settled;
        }
        if(game.vrfBlock != 0) {
            if(block.number >= game.vrfBlock) {
                return STATUS.pendingsettlement;
            } else {
                return STATUS.pendingVrfBlock;
            }
        }
        if(game.player1 != address(0) && game.player2 != address(0)) {
            return STATUS.pendingflip;
        }
        if(game.player1 == address(0) || game.player2 == address(0)) {
            return STATUS.created;
        }
    } 

    function _calculateFee(uint price) private view returns(uint) {
        return (price * _fee) / 1e2;
    }

    function retrieveTokens(uint amount) public override onlyOwner {
        _token.transfer(msg.sender, amount);
    }
}