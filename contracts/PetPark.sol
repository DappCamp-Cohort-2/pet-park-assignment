//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {
  address owner;
  mapping(uint8 => uint) public animalMap;
  mapping(address => uint) public borrowers;

  event Added(uint8 _animalType, uint _count);
  event Borrowed(uint8 _animalType);
  event Returned(uint8 _animalType);

  constructor() {
    owner = msg.sender;
  }

  modifier isOwner() {
    require(msg.sender == owner, 'Not an owner');
    _;
  }

  modifier isAnimalTypeValid(uint8 _animalType) {
    require(_animalType > 0 && _animalType <= 5, 'Invalid animal');
    _;
  }

  function add(uint8 _animalType, uint256 _count) public isOwner isAnimalTypeValid(_animalType) {
    animalMap[_animalType] += _count;
    emit Added(_animalType, _count);
  }

}