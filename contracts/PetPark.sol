//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/// @title A smart contract development exercise for Dappcamp 
/// @author Shunichiro Mimura
contract PetPark {

    address owner;
    mapping(int256 => int256) animalCount;

    constructor() {
      owner = msg.sender;
    }

    modifier onlyOwner {
      require(msg.sender == owner, "Not an owner");
      _;
    }

    modifier invalidAnimal(int256 animalType) {
      require(1 <= animalType && animalType <= 5, "Invalid animal");
      _;
    }

   event Added(int256 animalType, int256 animalCount);

    /**
    Takes Animal Type and Count. Gives shelter to animals in our park.
    Only contract owner (address deploying the contract) should have access to this functionality.
    Emit event Added with parameters Animal Type and Animal Count.
    */
    function add(int256 animalType, int256 count) public onlyOwner invalidAnimal(animalType) {
        require(1 <= animalType && animalType <= 5, "Invalid animal");
        animalCount[animalType] += count;
        emit Added(animalType, count);
    }

    /**
    Takes Age, Gender and Animal Type.
    Can borrow only one animal at a time. Use function giveBackAnimal to borrow another animal.
    Men can borrow only Dog and Fish.
    Women can borrow every kind, but women aged under 40 are not allowed to borrow a Cat.
    Throw an error if an address has called this function before using other values for Gender and Age.
    Emit event Borrowed with parameter Animal Type.
    */
    function borrow(int age, int gender, int animalType) public {

    }

    /** 
    Throw an error if user hasn't borrowed before.
    Emit event Returned with parameter Animal Type. 
    */
    function giveBackAnimal() public {

    }

}