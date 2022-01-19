//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    address owner;

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

    struct AddressDetails {
        uint age;
        Gender gender;
        bool hasSetAddressDetails;
    }

    struct Animal {
        AnimalType animalType;
    }

    mapping (AnimalType => uint) unborrowedAnimals;
    mapping (address => AnimalType) borrowedAnimalByAddress;
    mapping (address => AddressDetails) addressDetails;

    event Added(AnimalType animalType, uint count);
    event Borrowed(AnimalType animalType);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    modifier validateAnimalType(AnimalType animalType, string memory errorMessage) {
        // Is there a cleaner way to do this?
        require(
            animalType == AnimalType.Fish || 
            animalType == AnimalType.Cat || 
            animalType == AnimalType.Dog || 
            animalType == AnimalType.Rabbit || 
            animalType == AnimalType.Parrot, errorMessage
        );
        _;
    }

    modifier hasNotBorrowedAnimal() {
        require(borrowedAnimalByAddress[msg.sender] == AnimalType.None, "Already adopted a pet");
        _;
    }

    modifier validateAnimalTypeForBorrower(uint age, Gender gender, AnimalType animalType) {
        if (gender == Gender.Male) {
            require(animalType == AnimalType.Fish || animalType == AnimalType.Dog, "Invalid animal for men");
        } else {
            require(age > 40 || animalType != AnimalType.Cat, "Invalid animal for women under 40");
        }
        _;
    }

    modifier validateGender(Gender gender) {
        require(gender == Gender.Male || gender == Gender.Female, "Invalid gender");
        _;
    }

    modifier validateAge(uint age) {
        require(age != 0, "Invalid Age");
        _;
    }

    modifier hasBorrowedAnimal() {
        require(borrowedAnimalByAddress[msg.sender] != AnimalType.None, "No borrowed pets");
        _;
    }
    
    modifier validateAnimalAvailable(AnimalType animalType) {
        require(unborrowedAnimals[animalType] != 0, "Selected animal not available");
        _;
    }

    modifier validateOwnerDetails(uint age, Gender gender) {
        require(!addressDetails[msg.sender].hasSetAddressDetails || addressDetails[msg.sender].age == age, "Invalid Age");
        require(!addressDetails[msg.sender].hasSetAddressDetails || addressDetails[msg.sender].gender == gender, "Invalid Gender");
        _;
    }

    function _createAnimal(AnimalType _animalType) private {
        unborrowedAnimals[_animalType] = unborrowedAnimals[_animalType] + 1;
    }

    function add(AnimalType animalType, uint count) external onlyOwner validateAnimalType(animalType, "Invalid animal") {
        for (uint i = 0; i < count; i++) {
            _createAnimal(animalType);
        }
        emit Added(animalType, count);
    }

    function _setAddressDetails(uint _age, Gender _gender) private {
        addressDetails[msg.sender] = AddressDetails(_age, _gender, true);
    }

    function borrow(uint age, Gender gender, AnimalType animalType) external validateAge(age) validateAnimalType(animalType, "Invalid animal type") validateAnimalAvailable(animalType) validateOwnerDetails(age, gender) hasNotBorrowedAnimal validateAnimalTypeForBorrower(age, gender, animalType) validateGender(gender) {
        if (!addressDetails[msg.sender].hasSetAddressDetails) {
            _setAddressDetails(age, gender);
        }
        borrowedAnimalByAddress[msg.sender] = animalType;
        unborrowedAnimals[animalType] = unborrowedAnimals[animalType] - 1;
        emit Borrowed(animalType);
    }

    function animalCounts(AnimalType animalType) external view returns(uint) {
        return unborrowedAnimals[animalType];
    }

    function giveBackAnimal() external hasBorrowedAnimal {
        AnimalType animalType = borrowedAnimalByAddress[msg.sender];
        borrowedAnimalByAddress[msg.sender] = AnimalType.None;
        unborrowedAnimals[animalType] = unborrowedAnimals[animalType] + 1;
    }
}