//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract PetPark {
    event Borrowed(uint256 animalType);
    event Returned(uint256 animalType);
    event Added(uint256 animalType, uint256 animalCount);
    error RejectedMessage(string msg);
    address owner;
    uint256 private fish = 1;
    uint256 private cat = 2;
    uint256 private dog = 3;
    uint256 private rabbit = 4;
    uint256 private parrot = 5;

    mapping(uint256 => uint256) public animalCounts;

    struct Borrower {
        uint256 animalType;
        uint256 gender;
        uint256 age;
        bool hasBorrowed;
    }

    mapping(address => Borrower) public borrowers;

    constructor() {
        owner = msg.sender;
    }

    modifier isOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    modifier validAnimalMod(uint256 _animalType) {
        require(_animalType > 0 && _animalType < 6, "Invalid animal");
        _;
    }

    function add(uint256 _animalType, uint256 _animalCount)
        public
        isOwner
        validAnimalMod(_animalType)
    {
        animalCounts[_animalType] = _animalCount;
        emit Added(_animalType, _animalCount);
    }

    modifier ageMod(uint256 _age) {
        require(_age != 0, "Invalid Age");

        _;
    }

    modifier genderReq(
        uint256 _age,
        uint256 _gender,
        uint256 _animalType
    ) {
        if (_gender == 0) {
            require(
                _animalType == dog || _animalType == fish,
                "Invalid animal for men"
            );
        }
        if (_gender == 1 && _age < 40) {
            require(_animalType != cat, "Invalid animal for women under 40");
        }
        _;
    }

    modifier calledBefore(uint256 _gender, uint256 _age) {
        if (borrowers[msg.sender].hasBorrowed) {
            require(borrowers[msg.sender].gender == _gender, "Invalid Gender");
            require(borrowers[msg.sender].age == _age, "Invalid Age");
        }
        _;
    }

    modifier animalAvailabilityMod(uint256 _animalType) {
        require(animalCounts[_animalType] > 0, "Selected animal not available");
        _;
    }
    modifier validAnimalTypeMod(uint256 _animalType) {
        require(_animalType > 0 && _animalType < 6, "Invalid animal type");
        _;
    }

    modifier alreadyBorrowedMod() {
        require(borrowers[msg.sender].animalType == 0, "Already adopted a pet");
        _;
    }

    function borrow(
        uint256 _age,
        uint256 _gender,
        uint256 _animalType
    )
        public
        ageMod(_age)
        validAnimalTypeMod(_animalType)
        animalAvailabilityMod(_animalType)
        calledBefore(_gender, _age)
        alreadyBorrowedMod
        genderReq(_age, _gender, _animalType)
    {
        Borrower memory updatedBorrower = Borrower(
            _animalType,
            _gender,
            _age,
            true
        );
        borrowers[msg.sender] = updatedBorrower;
        animalCounts[_animalType]--;
        emit Borrowed(_animalType);
    }

    function giveBackAnimal() public {
        require(borrowers[msg.sender].animalType != 0, "No borrowed pets");
        uint256 animalToReturn = borrowers[msg.sender].animalType;
        borrowers[msg.sender].animalType = 0;
        animalCounts[animalToReturn]++;
        emit Returned(animalToReturn);
    }
}
