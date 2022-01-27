//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
struct Game {
        string name;

        uint price;

        address player1;
        address player2;

        address winner;

        uint vrfBlock;
}