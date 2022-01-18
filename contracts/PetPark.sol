// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PetPark {

    mapping (AnimalType => uint) petPark;
	address owner;
    mapping (address => Borrower) borrowers;
    // mapping (address => mapping(AnimalType => uint)) ledger;
	// let account1;
    struct Borrower {
        bool borrowed;
        Gender _gender;
        uint _age;
        AnimalType _type;
    }
    // mapping (address => bool) didBorrow;

    

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

    event Added(AnimalType _type, uint _count);
    event Borrowed(AnimalType _type);
    event Returned(AnimalType _type);
    constructor () {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    modifier allowedAnimals(AnimalType _type) {
        require(uint8(_type) > 0 && uint8(_type) <= 5, "Invalid animal type");
        _;
    }

    function animalCounts(AnimalType _type) public view returns(uint) {
        return petPark[_type];
    }

    function add(AnimalType _type, uint _count) public onlyOwner allowedAnimals(_type) {
        petPark[_type] += _count;

        emit Added(_type, _count);
    }

    function borrow(uint _age, Gender _gender, AnimalType _type) public allowedAnimals(_type) {
        if (_age == 0 ) {
            revert("Invalid Age");
        }

        if (petPark[_type]==0) {
            revert("Selected animal not available");
        }

        // if (borrowers[msg.sender].borrowed) {
        //     revert("Already adopted a pet");
        // } 

        // if (borrowers[msg.sender].borrowed && borrowers[msg.sender]._gender != _gender) {
        //     revert("Invalid Gender");
        //     revert("Already adopted a pet");
        // } 
        
        if (borrowers[msg.sender].borrowed) {
            if (borrowers[msg.sender]._age != _age) {
                revert("Invalid Age");
            } else if (borrowers[msg.sender]._gender != _gender) {
                revert("Invalid Gender");
            } else {
                revert("Already adopted a pet");
            }
        } 

        if (_gender == Gender.Male) { //men
            if (_type != AnimalType.Dog && _type != AnimalType.Fish) {
                revert("Invalid animal for men");
            }
        } else { //women
            if (_gender == Gender.Female && _type == AnimalType.Cat) {
                revert("Invalid animal for women under 40");
            }
        }

        borrowers[msg.sender] = Borrower({borrowed: true, _gender: _gender, _age: _age, _type: _type});
        petPark[_type]--;
        emit Borrowed(_type);

    }

    function giveBackAnimal() public {
        require(borrowers[msg.sender].borrowed,"No borrowed pets");
        
        petPark[borrowers[msg.sender]._type]++;
        emit Returned(borrowers[msg.sender]._type);
        delete borrowers[msg.sender];

    }

}