//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract PetPark {

  address owner;
  enum AnimalType {
    None,
    Fish,
    Cat,
    Dog,
    Rabbit,
    Parrot
  }
  mapping(AnimalType => uint) animalsInShelter;
  enum Gender {
    Male,
    Female
  }
  struct Borrower {
    Gender gender;
    uint age;
    AnimalType borrowed;
    bool visited;
  }
  mapping(address => Borrower) borrowers;

  event Added(AnimalType _animalType, uint _count);
  event Borrowed(AnimalType _animalType);
  event Returned(AnimalType _animalType);

  constructor() {
    owner = msg.sender;
  }

  modifier isOwner() {
    if (msg.sender != owner)
      revert("Not an owner");
    _;
  }

  function add(AnimalType _animalType, uint _count) external isOwner() {
    if(_animalType < AnimalType.Fish || _animalType > AnimalType.Parrot)
      revert("Invalid animal");

    animalsInShelter[_animalType] += _count;

    emit Added(_animalType, _count);
  }

  function borrow(uint _age, Gender _gender, AnimalType _animalType) public {
    if(_age == 0)
      revert("Invalid Age");

    if(_animalType == AnimalType.None || _animalType > AnimalType.Parrot)
      revert("Invalid animal type");

    if(animalsInShelter[_animalType] == 0)
      revert("Selected animal not available");

    if(borrowers[msg.sender].visited) {
      if(borrowers[msg.sender].age != _age)
        revert("Invalid Age");
      
      if(borrowers[msg.sender].gender != _gender)
        revert("Invalid Gender");
    }
    
    if(borrowers[msg.sender].borrowed != AnimalType.None)
      revert("Already adopted a pet");

    if(_gender == Gender.Male && _animalType != AnimalType.Dog && _animalType != AnimalType.Fish)
      revert("Invalid animal for men");

    if(_gender == Gender.Female && _age < 40 && _animalType == AnimalType.Cat)
      revert("Invalid animal for women under 40");

    borrowers[msg.sender].age = _age;
    borrowers[msg.sender].gender = _gender;

    animalsInShelter[_animalType] -= 1;
    borrowers[msg.sender].visited = true;
    borrowers[msg.sender].borrowed = _animalType;

    emit Borrowed(_animalType);
  }

  function animalCounts(AnimalType _animalType) public view returns(uint count) {
    return animalsInShelter[_animalType];
  }

  function giveBackAnimal() public {
    if(borrowers[msg.sender].borrowed == AnimalType.None)
      revert("No borrowed pets");

    emit Returned(borrowers[msg.sender].borrowed);

    animalsInShelter[borrowers[msg.sender].borrowed]++;
    borrowers[msg.sender].borrowed = AnimalType.None;
  }
}