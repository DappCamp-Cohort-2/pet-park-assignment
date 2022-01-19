//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {
  address public owner;

  constructor() {
    owner = msg.sender;
  }

  enum AnimalType {
    None,
    Fish,
    Cat,
    Dog,
    Rabbit,
    Parrot
  }

  enum Gender {
    Male,
    Female
  }

  struct borrower {
    Gender gender;
    AnimalType animal;
    uint age;
    bool hasBorrowed;
  }

  event Added(AnimalType animalType, uint count);
  event Borrowed(AnimalType animalType);

  mapping(AnimalType => uint) public animalCounts;
  mapping(address => AnimalType) public animalTypesBorrowed;
  mapping(address => borrower) public   animalsBorrowedByAddress;

  modifier validateSender() {
    if(msg.sender != owner) {
      revert("Not an owner");
    }
    _;
  }

  modifier revertIfNone(AnimalType _animal) {
    if(_animal == AnimalType.None) {
      revert("Invalid animal type");
    }
    _;
  }

  modifier checkAge(uint _age) {
    if(_age == 0) {
      revert("Invalid Age");
    }
    _;
  }

  modifier animalNotAvailable(AnimalType _animalType) {
    if(animalCounts[_animalType] == 0) {
      revert("Selected animal not available");
    }
    _;
  }

  modifier womenCannotBorrow(Gender _gender, uint _age, AnimalType _animalType) {
    if(_gender == Gender.Female && _age < 40 && _animalType == AnimalType.Cat) {
      revert("Invalid animal for women under 40");
    }
    _;
  }

  modifier hasBorrowedBefore(uint _age, Gender _gender) {
    borrower memory _borrower = animalsBorrowedByAddress[msg.sender];
    if(_borrower.hasBorrowed) {
      
      if(_borrower.gender != _gender) {
        revert("Invalid Gender");
      }
      
      if(_borrower.age != _age) {
        revert("Invalid Age");
      }
    }
    _;
  }

  modifier hasNotBorrowedBefore() {
    borrower memory _borrower = animalsBorrowedByAddress[msg.sender];
    if(!_borrower.hasBorrowed) {
      revert("No borrowed pets");
    }
    _;
  }

  function add(AnimalType _animalType, uint _count) public validateSender revertIfNone(_animalType) {
    animalCounts[_animalType] += _count; 
    emit Added(_animalType, _count);
  }

  function borrow(uint _age, Gender _gender, AnimalType _animalType) public checkAge(_age) 
  revertIfNone(_animalType) 
  animalNotAvailable(_animalType)
  womenCannotBorrow(_gender, _age, _animalType)
  hasBorrowedBefore(_age, _gender) {
    _validateBorrow(_gender, _animalType);
    animalCounts[_animalType] -= 1;
    animalTypesBorrowed[msg.sender] = _animalType;
    animalsBorrowedByAddress[msg.sender] = borrower(_gender, _animalType, _age, true);
    emit Borrowed(_animalType);
  }

  function giveBackAnimal() public hasNotBorrowedBefore {
    AnimalType _animals = animalTypesBorrowed[msg.sender];
    animalTypesBorrowed[msg.sender] = AnimalType.None;
    animalCounts[_animals] += 1;
  }

  function _validateBorrow(Gender _gender, AnimalType _animalType) private view{
    if(animalTypesBorrowed[msg.sender] != AnimalType.None) {
      revert("Already adopted a pet");
    }

    if(_gender == Gender.Male && (_animalType != AnimalType.Dog && _animalType != AnimalType.Fish)) {
      revert("Invalid animal for men");
    }
  }
}