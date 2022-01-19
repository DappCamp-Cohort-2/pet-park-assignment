//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "hardhat/console.sol";

contract PetPark {
    event Added(AnimalType indexed animalType, uint indexed amount);
    event Borrowed(AnimalType indexed animalType);
    address immutable owner;

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

    struct BorrowerDetails {
        uint age;
        Gender gender;
        AnimalType animalBorrowing;
        uint numAnimalsBorrowed;
        bool initialized;
    }

    mapping(AnimalType => uint) public animalCounts;
    mapping(address => AnimalType) borrowerToAnimal;
    mapping(address => uint) borrowerToAge; 
    mapping(address => uint) borrowerToTotalAnimalsBorrowed; 
    mapping(address => Gender) borrowerToGender; 


    modifier onlyOwner() {
        require(owner == msg.sender, "Not an owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function giveBackAnimal() external {
        require(borrowerToTotalAnimalsBorrowed[msg.sender] != 0, "No borrowed pets");
        animalCounts[borrowerToAnimal[msg.sender]]++;
    }

    function add(AnimalType _animalType, uint amount) external onlyOwner {
           require(
        _animalType == AnimalType.Fish ||
        _animalType == AnimalType.Cat  ||
        _animalType == AnimalType.Dog ||
        _animalType == AnimalType.Rabbit ||
        _animalType == AnimalType.Parrot, "Invalid animal type");

        animalCounts[_animalType] = animalCounts[_animalType] + amount;
        emit Added(_animalType, amount);
    }

    function borrow(uint _age, Gender _gender, AnimalType _animalType)  external {

        require(_age > 0, "Invalid Age");
 
        if (uint(_animalType) == uint(AnimalType.None)) {
            revert("Invalid animal type");
        }

        if (borrowerToTotalAnimalsBorrowed[msg.sender] == 0) {
            borrowerToAge[msg.sender] = _age;
            borrowerToGender[msg.sender] = _gender;
            borrowerToAnimal[msg.sender] = AnimalType.None;
        } else {
                            if (borrowerToTotalAnimalsBorrowed[msg.sender] > 0 && borrowerToAge[msg.sender] != _age) {
            revert("Invalid Age");
        }

        if (borrowerToTotalAnimalsBorrowed[msg.sender] > 0 && borrowerToGender[msg.sender] != _gender) {
            revert("Invalid Gender");
        }
        }

        require(animalCounts[_animalType] > 0, "Selected animal not available");

        require(borrowerToAnimal[msg.sender] == AnimalType.None, "Already adopted a pet");

        if (_gender == Gender.Male) {
            require(_animalType == AnimalType.Fish || _animalType == AnimalType.Dog, "Invalid animal for men");
        }

        if (_gender == Gender.Female && _age < 40 && _animalType == AnimalType.Cat) { 
            revert("Invalid animal for women under 40"); 
        }

        borrowerToTotalAnimalsBorrowed[msg.sender]++;
        borrowerToAnimal[msg.sender] = _animalType;
        animalCounts[_animalType]--;

        

        emit Borrowed(_animalType);
    }
}