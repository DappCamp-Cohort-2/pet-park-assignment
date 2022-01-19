//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/*
add

Takes Animal Type and Count. Gives shelter to animals in our park.
Only contract owner (address deploying the contract) should have access to this functionality.
Emit event Added with parameters Animal Type and Animal Count.
borrow

Takes Age, Gender and Animal Type.
Can borrow only one animal at a time. Use function giveBackAnimal to borrow another animal.
Men can borrow only Dog and Fish.
Women can borrow every kind, but women aged under 40 are not allowed to borrow a Cat.
Throw an error if an address has called this function before using other values for Gender and Age.
Emit event Borrowed with parameter Animal Type.
giveBackAnimal

Throw an error if user hasn't borrowed before.
Emit event Returned with parameter Animal Type.
*/

contract PetPark {
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

    struct UserInfo {
		Gender gender;
		uint8 age;
	}

    event Added(AnimalType animalType, uint count);
    event Borrowed(AnimalType animalType);
    event Returned(AnimalType animalType);

    // storage
    address private owner;

    mapping (address => AnimalType) pets;
    mapping (AnimalType => uint) park;
    mapping (address => UserInfo) users;

    //
    constructor() {
        owner = msg.sender;
    }

    // functions

    function add(AnimalType animalType, uint count) external isOwner isValidAnimal(animalType) {
        park[animalType] += count;

        emit Added(animalType, count);
    }

    function borrow(uint8 age, Gender gender, AnimalType animalType) external isValidAnimal(animalType) isValidGender(gender) {
        require(age > 0, "Invalid Age");
        require(users[msg.sender].gender == gender || users[msg.sender].age == 0, "Invalid Gender");
        require(users[msg.sender].age == age || users[msg.sender].age == 0, "Invalid Age");
        require(pets[msg.sender] == AnimalType.None, "Already adopted a pet");
        require(park[animalType] > 0, "Selected animal not available");
        require(gender == Gender.Female || (animalType == AnimalType.Fish || animalType == AnimalType.Dog), "Invalid animal for men");
        require(gender == Gender.Male || (animalType != AnimalType.Cat || age >= 40), "Invalid animal for women under 40");
        
        users[msg.sender] = UserInfo(gender, age);
        park[animalType]--;
        pets[msg.sender] = animalType;

        emit Borrowed(animalType);
    }

    function giveBackAnimal() external {
        require(pets[msg.sender] != AnimalType.None, "No borrowed pets");

        AnimalType animalType = pets[msg.sender];
        pets[msg.sender] = AnimalType.None;
        park[animalType]++;

        emit Returned(animalType);
    }

    function animalCounts(AnimalType animalType) public view returns (uint) {
        return park[animalType];
    }

    // modifiers

    modifier isOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    modifier isValidAnimal(AnimalType animalType) {
        require(animalType > AnimalType.None && animalType <= AnimalType.Parrot, "Invalid animal type");
        _;
    }

    modifier isValidGender(Gender gender) {
        require(gender >= Gender.Male && gender <= Gender.Female);
        _;
    }
}