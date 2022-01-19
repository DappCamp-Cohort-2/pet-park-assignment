//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/**
 * @title A pet park with borrowing capabilities
 * @author Lucas Janon
 */
contract PetPark {
  enum AnimalType { None, Fish, Cat, Dog, Rabbit, Parrot }
  enum Gender { Male, Female }

  address owner;

  struct Member {
    Gender gender;
    uint256 age;
  }

  mapping (AnimalType => uint256) public animalCounts;
  mapping (address => AnimalType) currentBorrowings;
  mapping (address => Member) parkMembers;

  event Added(AnimalType animalType, uint256 animalCounts);
  event Borrowed(AnimalType animalType);
  event Returned(AnimalType animalType);

  constructor() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Not an owner");
    _;
  }

  modifier validateAge(uint256 _age) {
    require(_age != 0, "Invalid Age");
    require(_age < 130, "Invalid Age");
    _;
  }

  function add(AnimalType _animalType, uint256 _count) public onlyOwner {
    require(_animalType != AnimalType.None, "Invalid animal");
    require(_count != 0, "Can't add 0 animals");

    animalCounts[_animalType] += _count;

    emit Added(_animalType, _count);
  }

  /**
   * @notice A park member (address) can borrow a single animal at the same time
   * @dev This method also creates a new park member if the msg.sender address didn't borrow before. 
   */
  function borrow(uint256 _providedAge, Gender _providedGender, AnimalType _animalType) public validateAge(_providedAge) {
    Member memory borrower = parkMembers[msg.sender];
    bool isParkMember = borrower.age != 0;

    if (isParkMember) {
      require(_providedAge == borrower.age, "Invalid Age");
      require(_providedGender == borrower.gender, "Invalid Gender");
    } else {
      Member memory newParkMember;

      newParkMember.age = _providedAge;
      newParkMember.gender = _providedGender;

      parkMembers[msg.sender] = newParkMember;
    }

    require(_animalType != AnimalType.None, "Invalid animal type");
    require(animalCounts[_animalType] >= 1, "Selected animal not available");
    require(currentBorrowings[msg.sender] == AnimalType.None, "Already adopted a pet");

    if (_providedGender == Gender.Male) {
      require(_animalType == AnimalType.Dog || _animalType == AnimalType.Fish, "Invalid animal for men");
    }

    if (_providedGender == Gender.Female && _providedAge < 40) {
      require(_animalType != AnimalType.Cat, "Invalid animal for women under 40");
    }

    currentBorrowings[msg.sender] = _animalType;
    animalCounts[_animalType] -= 1;

    emit Borrowed(_animalType);
  }

  function giveBackAnimal() public {
    require(currentBorrowings[msg.sender] != AnimalType.None, "No borrowed pets");

    AnimalType _animalType = currentBorrowings[msg.sender];

    delete currentBorrowings[msg.sender];
    animalCounts[_animalType] += 1;

    emit Returned(_animalType);
  }
}
