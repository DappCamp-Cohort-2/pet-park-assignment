//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/// @title A contract for Pet Park implementation
/// @author Ashwin Rachakonda 💯💯😎💯💯
/// @notice Used to managing animals in the pet park and also lets users to borrow them
contract PetPark{
    address private _owner;
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

    struct Borrower {
        uint8 age;
        Gender gender;
    }
    
    event Added(AnimalType animalType, uint animalCount);
    event Borrowed(AnimalType animalType);
    event Returned(AnimalType animalType);

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Not an owner");
        _;
    }

    modifier validAge(uint age) {
        require(age > 0, "Invalid Age");
        _;
    }

    modifier validAnimal(AnimalType animalType) {
        require(animalType == AnimalType.Fish || animalType == AnimalType.Cat || animalType == AnimalType.Dog || animalType == AnimalType.Rabbit || animalType == AnimalType.Parrot, "Invalid animal type");
        _;
    }

    modifier validHuman(Gender gender) {
        require(gender == Gender.Male || gender == Gender.Female, "Invalid human type");
        _;
    }

    mapping(AnimalType => uint) public animalCounts;//Map of animal and the their respective count
    mapping(address => AnimalType) private borrowerAnimalMap;//Map of user and the type of animal borrowed
    mapping(address => Borrower) private borrowerToAgeGenderMap;//Map of user to age, gender map to make sure user is not borrowing with different values
     
    /// @notice Adds animals to the park
    /// @param _animalType type of animal.
    /// @param _animalCount number of animals.
    function add(AnimalType _animalType, uint _animalCount) external onlyOwner validAnimal(_animalType) {
        //update map
        animalCounts[_animalType]+=_animalCount;
        emit Added(_animalType, _animalCount);
    }

    /// @notice Lets users borrow animals
    /// @param _age age of user borrowing.
    /// @param _gender gender of user borrowing.
    /// @param _animalType type of animal user wants to borrow.
    function borrow(uint8 _age, Gender _gender, AnimalType _animalType) external validAge(_age) validAnimal(_animalType) validHuman(_gender) {
        Borrower memory borrower = borrowerToAgeGenderMap[msg.sender];
        //check if address has called this function before using other values for Gender and Age
        if(borrower.age > 0) {
            require(borrower.age == _age, "Invalid Age");
            require(borrower.gender == _gender, "Invalid Gender");
        }
        //Can borrow only one animal at a time
        require(borrowerAnimalMap[msg.sender] == AnimalType.None, "Already adopted a pet");
        //Men can only borrow Dog and Fish
        if(_gender == Gender.Male){
            require(_animalType == AnimalType.Fish || _animalType == AnimalType.Dog, "Invalid animal for men");
        } 
        //Women can borrow every kind, but women aged under 40 are not allowed to borrow a Cat
        else{
            require(_animalType != AnimalType.Cat && _age < 40, "Invalid animal for women under 40");
        }
        //animal is not available to borrow
        require(animalCounts[_animalType] > 0, "Selected animal not available");

        //update maps
        animalCounts[_animalType]--;
        borrowerAnimalMap[msg.sender] = _animalType;
        borrowerToAgeGenderMap[msg.sender] = Borrower(_age, _gender);
        emit Borrowed(_animalType);
    }

    /// @notice Lets users give animals back
    function giveBackAnimal() external {
        //user hasn't borrowed before
        require(borrowerAnimalMap[msg.sender] > AnimalType.None, "No borrowed pets");

        //update maps
        AnimalType animalType = borrowerAnimalMap[msg.sender];
        animalCounts[animalType]++;
        borrowerAnimalMap[msg.sender] = AnimalType.None;
        emit Returned(animalType);
    }
}