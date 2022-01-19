//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/// @title A smart contract development exercise for Dappcamp 
/// @author Shunichiro Mimura
contract PetPark {

    /**
    Takes Animal Type and Count. Gives shelter to animals in our park.
    Only contract owner (address deploying the contract) should have access to this functionality.
    Emit event Added with parameters Animal Type and Animal Count.
    */
    function add() public {

    }

    /**
    Takes Age, Gender and Animal Type.
    Can borrow only one animal at a time. Use function giveBackAnimal to borrow another animal.
    Men can borrow only Dog and Fish.
    Women can borrow every kind, but women aged under 40 are not allowed to borrow a Cat.
    Throw an error if an address has called this function before using other values for Gender and Age.
    Emit event Borrowed with parameter Animal Type.
    */
    function borrow() public {

    }

    /** 
    Throw an error if user hasn't borrowed before.
    Emit event Returned with parameter Animal Type. 
    */
    function giveBackAnimal() public {

    }

}