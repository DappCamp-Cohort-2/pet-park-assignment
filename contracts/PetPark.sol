//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {
	struct Animal {
		uint animalType;
		uint256 count;
	}

	struct Person {
		uint age;
		uint gender;
		uint borrowedAnimal;
	}

	address private _owner;
	mapping (uint => Animal) private animals;
	mapping (address => Person) private animalOwners;
	mapping (uint => uint) public animalCounts;


	event Added(
		uint animalType,
		uint count
	);

	event Borrowed(
		uint animalType
	);

	constructor() {
		_owner = msg.sender;
	}

	function add(uint _animalType, uint _count) public {
		require(msg.sender == _owner, "Not an owner");

		if (_animalType < 1 || _animalType > 5) {
			revert("Invalid animal");
		}

		animals[_animalType] = Animal(_animalType, _count);
		animalCounts[_animalType] += _count;

		emit Added(_animalType, _count);
	}

	function borrow(uint _age, uint _gender, uint _animalType) public {
		if (_age == 0) {
			revert("Invalid Age");
		}

		if (_animalType < 1 || _animalType > 5) {
			revert("Invalid animal type");
		}

		if (animals[_animalType].count == 0) {
			revert("Selected animal not available");
		}

		if (animalOwners[msg.sender].age != 0 && animalOwners[msg.sender].age != _age) {
			revert("Invalid Age");
		}

		if (animalOwners[msg.sender].age != 0 && animalOwners[msg.sender].gender != _gender) {
			revert("Invalid Gender");
		}

		if (animalOwners[msg.sender].borrowedAnimal != 0) {
			revert("Already adopted a pet");
		}

		// Men can only borrow fish or dogs
		if (_gender == 0 && (_animalType == 2 || _animalType == 4 || _animalType == 5)) {
			revert("Invalid animal for men");
		}

		// Women under 40 cannot borrow cats
		if (_gender == 1 && _animalType != 1 && _age < 40) {
			revert("Invalid animal for women under 40");
		}

		animals[_animalType].count -= 1;
		animalCounts[_animalType] -= 1;
		animalOwners[msg.sender] = Person(_age, _gender, _animalType);

		emit Borrowed(_animalType);
	}

	function giveBackAnimal() public {
		if (animalOwners[msg.sender].borrowedAnimal == 0) {
			revert("No borrowed pets");
		}

		animalCounts[animalOwners[msg.sender].borrowedAnimal] += 1;
		animals[animalOwners[msg.sender].borrowedAnimal].count += 1;
		animalOwners[msg.sender].borrowedAnimal = 0;
	}
}