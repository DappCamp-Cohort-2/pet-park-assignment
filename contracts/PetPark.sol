//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


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
  mapping(address => Gender) genders;
  mapping(address => uint) ages;
  mapping(address => bool) borrowed;
  mapping(address => AnimalType) borrowedAnimalType;
  mapping(address => bool) returning;

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

  function add(AnimalType _animalType, uint _count) public isOwner() {
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

    if(returning[msg.sender]) {
      if(ages[msg.sender] != _age)
        revert("Invalid Age");
      
      if(genders[msg.sender] != _gender)
        revert("Invalid Gender");
    }
    
    if(borrowed[msg.sender])
      revert("Already adopted a pet");

    if(_gender == Gender.Male && _animalType != AnimalType.Dog && _animalType != AnimalType.Fish)
      revert("Invalid animal for men");

    if(_gender == Gender.Female && _age < 40 && _animalType == AnimalType.Cat)
      revert("Invalid animal for women under 40");

    ages[msg.sender] = _age;
    genders[msg.sender] = _gender;
    returning[msg.sender] = true;

    animalsInShelter[_animalType] -= 1;
    borrowed[msg.sender] = true;
    borrowedAnimalType[msg.sender] = _animalType;
    
    emit Borrowed(_animalType);
  }

  function animalCounts(AnimalType _animalType) public view returns(uint count) {
    return animalsInShelter[_animalType];
  }

  function giveBackAnimal() public {
    if(!borrowed[msg.sender])
      revert("No borrowed pets");

    emit Returned(borrowedAnimalType[msg.sender]);

    animalsInShelter[borrowedAnimalType[msg.sender]]++;
    borrowed[msg.sender] = false;
    borrowedAnimalType[msg.sender] = AnimalType.None;
  }
}