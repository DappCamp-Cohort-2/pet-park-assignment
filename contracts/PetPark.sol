//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {

    address immutable owner;

    // caller profiles
    enum Gender {Male,Female}
    struct Profile {
        Gender gender;
        uint age;
        AnimalType borrowedAnimalType;
    }
    mapping(address => Profile) addressToProfile;

    // animals profiles
    enum AnimalType {Undefined, Fish, Cat, Dog, Rabbit, Parrot}
    struct Animal {
        AnimalType _type;
    }
    mapping(AnimalType => uint) public animalCounts;

    // events
    event Added(uint animalType, uint animalCount);
    event Borrowed(AnimalType animalType);
    event Returned(AnimalType animalType);

    constructor() {
        owner = msg.sender;
    }

    modifier isOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    modifier isValidAnimalType(uint animalType, string memory errMsg) {
        require(animalType > uint(AnimalType.Undefined) && animalType <= uint(AnimalType.Parrot), errMsg);
        _;
    }

    modifier isValidAge(uint age) {
        require(age > 0, "Invalid Age");
        _;
    }

    function add(uint animalType, uint count) external isOwner isValidAnimalType(animalType, "Invalid animal") {
        animalCounts[AnimalType(animalType)] += count;
        
        emit Added(animalType, animalCounts[AnimalType(animalType)]);
    }

function borrow(uint age, Gender gender, uint animalType) external 
    isValidAge(age) 
    isValidAnimalType(animalType, "Invalid animal type")  {
        AnimalType _animalType = AnimalType(animalType);

        // doing these checks her einstead of modifiers as all these checks are specific 
        // to this function.

        // check profile mismatches and if user already adoped a pet
        if (addressToProfile[msg.sender].age > 0) {
            Profile memory _profile = addressToProfile[msg.sender];
            require(_profile.age == age, "Invalid Age");
            require(_profile.gender == gender, "Invalid Gender");
            require(_profile.borrowedAnimalType == AnimalType.Undefined, "Already adopted a pet");
        }
        // check if valid type for gender / age
        if (gender == Gender.Male) {
            require(_animalType == AnimalType.Dog || _animalType == AnimalType.Fish, "Invalid animal for men");
        } else {
            if (age < 40) {
                require(_animalType != AnimalType.Cat, "Invalid animal for women under 40");
            }
        }

        require(animalCounts[_animalType] > 0, "Selected animal not available");
        animalCounts[_animalType] -= 1;
        Profile memory profile = Profile({gender: gender, age: age, borrowedAnimalType: _animalType});
        addressToProfile[msg.sender] = profile;

        emit Borrowed(_animalType);
    }

    function giveBackAnimal() external {
        require(addressToProfile[msg.sender].borrowedAnimalType != AnimalType.Undefined, "No borrowed pets");
        Profile storage profile = addressToProfile[msg.sender];
        animalCounts[profile.borrowedAnimalType] += 1;
        profile.borrowedAnimalType = AnimalType.Undefined;

        emit Returned(profile.borrowedAnimalType);
    }
}