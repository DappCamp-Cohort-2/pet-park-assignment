//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PetPark {
    // Libraries
    using SafeMath for uint256;
    // Structs
    struct Borrower {
        uint age;
        Gender gender;
    }
    // Enums
    enum AnimalType { NONE, FISH, CAT, DOG, RABBIT, PARROT }
    enum Gender { MALE, FEMALE }
    // Events
    event Added(AnimalType animalType, uint count);
    event Borrowed(AnimalType animalType);
    event Returned(AnimalType animalType);
    // State variables
    mapping (address => AnimalType) private _borrowedAnimals;
    mapping (address => Borrower) private _borrowerHistory;
    mapping (AnimalType => uint) private _animalCount;
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Not an owner");
        _;
    }

    function add(AnimalType animalType, uint count) onlyOwner public {
        require(animalType > AnimalType.NONE && animalType <= AnimalType.PARROT, "Invalid animal type");
        _animalCount[animalType] = SafeMath.add(_animalCount[animalType], count);
        emit Added(animalType, count);
    }

    function borrow(uint age, Gender gender, AnimalType animalType) public {
        _checkAndTrackBorrower(age, gender);
        require(animalType > AnimalType.NONE && animalType <= AnimalType.PARROT, "Invalid animal type");
        require(age > 0, "Invalid Age");
        require(_borrowedAnimals[msg.sender] == AnimalType.NONE, "Already adopted a pet");
        require(_animalCount[animalType] > 0, "Selected animal not available");
        if (gender == Gender.MALE) {
            require(animalType == AnimalType.DOG || animalType == AnimalType.FISH, "Invalid animal for men");
        } else if (gender == Gender.FEMALE) {
            if (animalType == AnimalType.CAT) {
                require(age >= 40, "Invalid animal for women under 40");
            }
        } else {
            revert("Unhandled gender");
        }
        _borrowedAnimals[msg.sender] = animalType;
        _animalCount[animalType] = SafeMath.sub(_animalCount[animalType], 1);
        emit Borrowed(animalType);
    }

    function _checkAndTrackBorrower(uint age, Gender gender) private {
        if (_borrowerHistory[msg.sender].age == 0 && _borrowerHistory[msg.sender].gender == Gender.MALE) {
            _borrowerHistory[msg.sender] = Borrower(age, gender);
        } else {
            require(_borrowerHistory[msg.sender].age == age, "Invalid Age");
            require(_borrowerHistory[msg.sender].gender == gender, "Invalid Gender");
        }
    }

    function giveBackAnimal() public {
        require(_borrowedAnimals[msg.sender] != AnimalType.NONE, "No borrowed pets");
        AnimalType animalReturned = _borrowedAnimals[msg.sender];
        _borrowedAnimals[msg.sender] = AnimalType.NONE;
        _animalCount[animalReturned] = SafeMath.add(_animalCount[animalReturned], 1);
        emit Returned(animalReturned);
    }

    function animalCounts(AnimalType animalType) public view returns (uint) {
        return _animalCount[animalType];
    }
}
