//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {
  enum AnimalType { None, Fish, Cat, Dog, Rabbit, Parrot }
  enum Gender { Male, Female }

  event Added(AnimalType Type, uint Count);
  event Borrowed(AnimalType Type);
  event Returned(AnimalType Type);

  struct Borrower {
    Gender gender;
    uint age;
  }

  mapping (AnimalType => uint) public animalCounts;
  mapping (address => AnimalType) private addressToBorrowedAnimal;
  mapping (address => Borrower) private addressToBorrower;
  address owner;

  constructor() {
    owner = msg.sender;
  }

  modifier isOwner() {
    require(msg.sender == owner, "Not an owner");
    _;
  }

  function isValidAnimal(AnimalType _type) private pure returns(bool) {
    return _type == AnimalType.Fish || _type == AnimalType.Cat || _type == AnimalType.Dog || _type == AnimalType.Rabbit || _type == AnimalType.Parrot;
  }

  function add(AnimalType _type, uint _count) public isOwner {
    require(isValidAnimal(_type), "Invalid animal");
    animalCounts[_type] += _count;
    emit Added(_type, animalCounts[_type]);
  }

  function borrow(uint _age, Gender _gender, AnimalType _type) public {
    require(_age > 0, "Invalid Age");
    if (addressToBorrower[msg.sender].age == 0) {
      addressToBorrower[msg.sender] = Borrower(_gender, _age);
    } else {
      require(addressToBorrower[msg.sender].gender == _gender, "Invalid Gender");
      require(addressToBorrower[msg.sender].age == _age, "Invalid Age");
    }
    require(isValidAnimal(_type), "Invalid animal type");
    // Can borrow only 1 animal at 1 time
    require(addressToBorrowedAnimal[msg.sender] == AnimalType.None, "Already adopted a pet");
    if (_gender == Gender.Male) {
      require(_type == AnimalType.Fish || _type == AnimalType.Dog, "Invalid animal for men");
    } else if (_gender == Gender.Female) {
      if (_type == AnimalType.Cat) { // Cat
        require(_age >= 40, "Invalid animal for women under 40");
      }
    }
    require(animalCounts[_type] > 0, "Selected animal not available");
    addressToBorrowedAnimal[msg.sender] = _type;
    animalCounts[_type] -= 1;
    emit Borrowed(_type);
  }

  function giveBackAnimal() public {
    require(addressToBorrowedAnimal[msg.sender] != AnimalType.None, "No borrowed pets");
    AnimalType a = addressToBorrowedAnimal[msg.sender];
    addressToBorrowedAnimal[msg.sender] = AnimalType.None;
    animalCounts[a] += 1;
    emit Returned(a);
  }

}
