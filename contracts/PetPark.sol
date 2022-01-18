//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {
  address owner;
  struct Borrower {
    uint age;
    uint gender;
    uint animalCount;
    uint animalType;
  }
  mapping(uint => uint) public petPark;
  mapping(address => Borrower) public borrowers;

  event Added(uint _animalType, uint _count);
  event Borrowed(uint _animalType);
  event Returned(uint _animalType);

  constructor() {
    owner = msg.sender;
  }

  modifier isOwner() {
    require(msg.sender == owner, "Not an owner");
    _;
  }

  function add(uint _animalType, uint256 _count) external isOwner animalTypeValidity(_animalType) {
    petPark[_animalType] += _count;
    emit Added(_animalType, _count);
  }

  function animalCounts(uint _animalType) external view returns (uint animalCount) {
    return petPark[_animalType];
  }

  function borrow(uint _age, uint _gender, uint _animalType) external nonZeroAge(_age) animalTypeValidity(_animalType) checkPreviousRequests(msg.sender, _gender, _age) hasNoPets(msg.sender) genderValidity(_gender, _age, _animalType) animalAvailability(_animalType) {
    borrowers[msg.sender] = Borrower(_age, _gender + 1, 1, _animalType);
    petPark[_animalType] -= 1;
    emit Borrowed(_animalType);
  }

  function giveBackAnimal() external hasBorrowedPets(msg.sender) {
    uint _animalType = borrowers[msg.sender].animalType;
    petPark[_animalType] += 1;
    emit Returned(_animalType);
  }

  modifier checkPreviousRequests(address _address, uint _gender, uint _age) {
    if (borrowers[_address].gender != 0 && borrowers[_address].gender != (_gender + 1)) {
      revert('Invalid Gender');
    }
    else if (borrowers[_address].age != 0 && borrowers[_address].age != _age) {
      revert('Invalid Age');
    }
    _;
  }

  modifier genderValidity(uint _gender, uint _age, uint _animalType) {
    if (_gender == 0 && !(_animalType == 1 || _animalType == 3)) {
      revert("Invalid animal for men");
    } else if (_gender == 1 && (_age < 40 && _animalType == 2)) {
      revert("Invalid animal for women under 40");
    }
    _;
  }

  modifier nonZeroAge(uint _age) {
    require(_age > 0, "Invalid Age");
    _;
  }

  modifier animalAvailability(uint _animalType) {
    require(petPark[_animalType] > 0, "Selected animal not available");
    _;
  }

  modifier animalTypeValidity(uint _animalType) {
    require(_animalType > 0 && _animalType <= 5, "Invalid animal type");
    _;
  }

  modifier hasNoPets(address _address) {
    require(borrowers[_address].animalCount == 0, "Already adopted a pet");
    _;
  }

  modifier hasBorrowedPets(address _address) {
    require(borrowers[_address].animalCount > 0, "No borrowed pets");
    _;
  }
}