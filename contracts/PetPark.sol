//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {
    
    address public owner;

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

    struct AnimalsBorrowed {
      uint animalType;
      uint animalCount;
    }

    struct Borrower {
        address bAddress;
        uint gender;
        uint age;
        uint animalType;
        uint animals;
    }

    mapping (uint => uint) public animalCounts;
    mapping (address => Borrower) public borrowersMap;


    event Added(uint animalType, uint animalCount);
    event Borrowed(uint animalType);
    event Returned(uint animalType);

    constructor () {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    // reusable helper
    function validAnimalCheck(uint _animalType) private pure returns (bool) {
      bool isValid = _animalType == uint(AnimalType.Fish) ||
        _animalType == uint(AnimalType.Cat) ||
        _animalType == uint(AnimalType.Dog) ||
        _animalType == uint(AnimalType.Rabbit) ||
        _animalType == uint(AnimalType.Parrot);

        return isValid;
    }

    modifier invalidAnimal(uint _animalType) {
      require(validAnimalCheck(_animalType),"Invalid animal");
      _;
    }

    // kept the seemilngly duplicate one to match the "tests" string
    modifier invalidAnimalType(uint _animalType) {
      require(validAnimalCheck(_animalType), "Invalid animal type");
      _;
    }

     modifier notAvailableAnimal(uint _animalType) {
      require(validAnimalCheck(_animalType), "Invalid animal type");
      require(
        animalCounts[_animalType] != 0,
        "Selected animal not available"
      );
      _;
    }

    modifier invalidAge(uint _age) {
       require(_age != 0, "Invalid Age");
      _;
    }

    modifier invalidGender(uint _gender) {
      require(
        _gender == uint(Gender.Male) || _gender == uint(Gender.Female),
        "Invalid Gender"
      );
      _;
    }

    modifier addressNotMismatch(address _borrower, uint _age, uint _gender) {
      Borrower storage borrower = borrowersMap[msg.sender];

      if (borrower.bAddress != address(0)) {
        require(borrowersMap[_borrower].age == _age, "Invalid Age");
        require(borrowersMap[_borrower].gender == _gender, "Invalid Gender");
      }
      _;
    }

    modifier alreadyAdopted(uint _animalType) {
      Borrower storage borrower = borrowersMap[msg.sender];

      if (borrower.bAddress != address(0)) {
        require(borrower.animals < 1, "Already adopted a pet");
      }
      _;
    }

    modifier notBorrowed() {
      Borrower storage borrower = borrowersMap[msg.sender];
      require(borrower.bAddress != address(0), "No borrowed pets");
      _;
    }

    function add(uint _animalType, uint _count) onlyOwner invalidAnimal(_animalType) public {
        animalCounts[_animalType] += _count;
        emit Added(_animalType, _count);
    }

    function borrow(uint _age, uint _gender, uint _animalType)
      addressNotMismatch(msg.sender, _age, _gender)
      alreadyAdopted(_animalType)
      invalidAge(_age)
      notAvailableAnimal(_animalType)
      invalidAnimalType(_animalType)
      invalidGender(_gender)
      public {

        if (_gender == uint(Gender.Male)) {
            if (_animalType != uint(AnimalType.Dog) && _animalType != uint(AnimalType.Fish)) {
              revert("Invalid animal for men");
            }
        }

        if (_gender == uint(Gender.Female)) {
            if (_age < 40 && _animalType == uint(AnimalType.Cat)) {
                revert("Invalid animal for women under 40");
            }
        }

       

        Borrower storage borrower = borrowersMap[msg.sender];

        if (borrower.bAddress == address(0)) {
          // 1st time borrow, no previous record
          borrower.bAddress = msg.sender;
          borrower.gender = _gender;
          borrower.age = _age;
          borrower.animals = 1;
          borrower.animalType = _animalType;

          borrowersMap[msg.sender] = borrower;
          animalCounts[_animalType]--;

        } else {
            require(borrower.age == _age, "Invalid Age");
            require(borrower.gender == _gender, "Invalid Gender");

            borrowersMap[msg.sender].animalType = _animalType;
            borrowersMap[msg.sender].animals++;
            animalCounts[_animalType]--;
        }

        emit Borrowed(_animalType);
    }

    function giveBackAnimal() notBorrowed public {
      Borrower storage borrower = borrowersMap[msg.sender];
      animalCounts[borrower.animalType]++;

      emit Returned(borrower.animalType);
    }
}