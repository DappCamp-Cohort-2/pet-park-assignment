//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
  enum AnimalType { None, Fish, Cat, Dog, Rabbit, Parrot }
  enum Gender { Male, Female }
  
  event Added(AnimalType animalType, uint count);
  event Borrowed(AnimalType animalType);
  event Returned(AnimalType animalType);

  mapping (address => AnimalType) public ownerToAnimal;
  mapping (address => uint) public ownerToAge;
  mapping (address => Gender) public ownerToGender;
  mapping (AnimalType => uint) public animalCounts;

  address private _owner;


  constructor() {
    _owner = msg.sender;
  }

  modifier onlyOwner() {
    if (msg.sender != _owner) {
      revert("Not an owner"); 
    }
    _;
  }


  function add(AnimalType animalType, uint count) public onlyOwner {
    if (animalType == AnimalType.None) {
      revert("Invalid animal");
    }

    animalCounts[animalType] = count;
    emit Added(animalType, count);
  }

  function borrow(uint age, Gender gender, AnimalType animalType) public {
    if (age == 0) {
      revert("Invalid Age");
    }

    if (animalType == AnimalType.None) {
      revert("Invalid animal type");
    }

    if (animalCounts[animalType] == 0) {
      revert("Selected animal not available");
    }

    if (ownerToAge[msg.sender] != 0 && ownerToAge[msg.sender] != age) {
      revert("Invalid Age");
    }

    if (gender == Gender.Female && age < 40 && animalType == AnimalType.Cat) {
      revert("Invalid animal for women under 40");
    }

    if ((ownerToGender[msg.sender] == Gender.Male || ownerToGender[msg.sender] == Gender.Female) && ownerToGender[msg.sender] != gender) {
      revert("Invalid Gender");
    }
    
    if (ownerToAnimal[msg.sender] != AnimalType.None) {
      revert("Already adopted a pet");
    }


    if (gender == Gender.Male && (animalType != AnimalType.Dog && animalType != AnimalType.Fish)) {
      revert("Invalid animal for men");
    }
    emit Borrowed(animalType);

    ownerToAnimal[msg.sender] = animalType;
    animalCounts[animalType] = animalCounts[animalType] - 1;
    ownerToAge[msg.sender] = age;
    ownerToGender[msg.sender] = gender;
  }

  function giveBackAnimal() public {
    AnimalType animal = ownerToAnimal[msg.sender];
    if (animal == AnimalType.None) {
      revert("No borrowed pets");
    }

    ownerToAnimal[msg.sender] = AnimalType.None;
    animalCounts[animal] = animalCounts[animal] + 1;
    emit Returned(animal);
  }
}