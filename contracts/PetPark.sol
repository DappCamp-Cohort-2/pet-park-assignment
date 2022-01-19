//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {
  // using SafeMath for uint;

  event Added(uint _animalType, uint _count);
  event Borrowed(uint _animalType);

  // @notice: AnimalType(1,2,3,4,5); respectively: Fish, Cat, Dog, Rabbit, Parrot)
  address owner;

  // @dev positional array to increment or decrement count
  uint[6] animals;
  
  struct Borrower{
    uint age; 
    uint gender;
    uint animalType;
    bool alreadyAdopted;
  }

  mapping (address => Borrower) private borrowers;

  constructor () {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Not an owner");
    _;
  }

  // @dev: will replace previous _count for the same _type OR accumulate _count
  function add(uint _type, uint _count) public onlyOwner {
    require((_type > 0) && (_type < 6), "Invalid animal");

    animals[_type] += _count;
    emit Added(_type, _count);
  }

  modifier notBorrowing() {
    require(borrowers[msg.sender].alreadyAdopted == false, "Already adopted a pet");
    _;
  }

  // @notice: Men can borrow Dog and Fish. 
  // @notice: Women can borrow every kind
  // @notice: women aged under 40 are not allowed to borrow a Cat.
  function borrow(uint _age, uint _gender, uint _type) public {  // notBorrowing {
    require((_type > 0) && (_type < 6), "Invalid animal type");
    require(_age > 0, "Invalid Age");
    require(animals[_type] > 0, "Selected animal not available");

    if (borrowers[msg.sender].age > 0) {
      require(_age == borrowers[msg.sender].age, "Invalid Age");
      require(_gender == borrowers[msg.sender].gender, "Invalid Gender");
    }

    require(borrowers[msg.sender].alreadyAdopted == false, "Already adopted a pet");
    
    if (_gender == 1){
      _woman_borrowing(_age, _gender, _type);
    }

    if (_gender == 0){
      _man_borrowing(_age, _gender, _type);
    }
    
  }

  function _woman_borrowing(uint _age, uint _gender, uint _type) private {
    require((_type != 2) || (_age > 40), "Invalid animal for women under 40");

    _borrowingAllowed(_age, _gender, _type);
  }

  function _man_borrowing(uint _age, uint _gender, uint _type) private {
    require((_type == 1) || (_type == 3), "Invalid animal for men");
    _borrowingAllowed(_age, _gender, _type);
  }

  function _borrowingAllowed(uint _age, uint _gender, uint _type) private {
    
    borrowers[msg.sender].age = _age; 
    borrowers[msg.sender].gender = _gender;
    borrowers[msg.sender].animalType = _type;
    borrowers[msg.sender].alreadyAdopted = true;
    
    --animals[_type];

    emit Borrowed(_type);
  }

  function giveBackAnimal() public {
    require(borrowers[msg.sender].alreadyAdopted, "No borrowed pets");

    ++animals[borrowers[msg.sender].animalType];
    borrowers[msg.sender].animalType = 0;
    borrowers[msg.sender].alreadyAdopted = false;

  }

  function animalCounts(uint _type) public view returns (uint){
    return animals[_type];
  }

}