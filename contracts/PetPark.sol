//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
	address owner;

	enum AnimalType  {
		None,
		Fish,
		Cat,
		Dog,
		Rabbit,
		Parrot
	}

	enum Gender  {
		Male,
		Female
	}

 	struct Borrower {
		Gender gender;
		uint age;
		bool hasBorrowed;
	}

	event Added(AnimalType animalType, uint count);
	event Borrowed (AnimalType animalType);

	mapping (AnimalType => uint) public animalCounts;
  	mapping (address => AnimalType) borrowedAnimals;
  	mapping (address => Borrower) petBorrowers;

	constructor ()  {
		owner = msg.sender;
	}

	function add(AnimalType _animalType, uint _count) public {
		validateAdd(_animalType);
		animalCounts[_animalType] += _count;
		emit Added(_animalType, _count);
	}

	function borrow(uint _age, Gender _gender, AnimalType _animalType) public {
		validateBorrow(_age, _gender, _animalType);
		animalCounts[_animalType]--;
		borrowedAnimals[msg.sender] = _animalType;
		petBorrowers[msg.sender] = Borrower(_gender, _age, true);
		emit Borrowed(_animalType);
	}

	function giveBackAnimal() public {
		validateGiveBackAnimal();
		AnimalType borrowedAnimal = borrowedAnimals[msg.sender];
		borrowedAnimals[msg.sender] = AnimalType.None;
		animalCounts[borrowedAnimal] += 1;
	}

	function validateAdd(AnimalType _animalType) private view {

		if (_animalType == AnimalType.None) {
			revert("Invalid animal");
		} 

		if (msg.sender != owner) {
			revert("Not an owner");
		} 
	}

	function validateBorrow(uint _age, Gender _gender, AnimalType _animalType) private view {

		if (_age == 0) {
			revert("Invalid Age");
		}

		Borrower memory borrower = petBorrowers[msg.sender];

		if (borrower.hasBorrowed) {
			if (borrower.gender != _gender) {
				revert("Invalid Gender");
			}
		
			if (borrower.age != _age) {
				revert("Invalid Age");
			}
		}
 
		if (_gender == Gender.Female && _age < 40 && _animalType == AnimalType.Cat){
			revert("Invalid animal for women under 40");
		}

		if (_animalType == AnimalType.None) {
			revert("Invalid animal type");
		}

		if (animalCounts[_animalType] == 0) {
			revert("Selected animal not available");
		}

		if (borrowedAnimals[msg.sender] != AnimalType.None) {
			revert("Already adopted a pet");
		}

		if (_gender == Gender.Male && (_animalType != AnimalType.Dog && _animalType != AnimalType.Fish)) {
			revert("Invalid animal for men");
		}
	}

	function validateGiveBackAnimal() private view {
		
		if (borrowedAnimals[msg.sender] == AnimalType.None) {
			revert("No borrowed pets");
		}
	}
}