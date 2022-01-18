//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    address owner;

    enum Gender {
        Male,
        Female
    }

    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }

    event Added(AnimalType _type, uint256 _count);
    event Borrowed(AnimalType _type);
    event Returned(AnimalType _type);

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert("Not an owner");
        }
        _;
    }

    mapping (AnimalType => uint256) private _totalAnimals;
    mapping (address => AnimalType) private _borrows;
    mapping (AnimalType => uint256) private _borrowedAnimals;
    mapping (address => uint) private _borrowerAge;
    mapping (address => Gender) private _borrowerGender;

    // Constructor: save owner for later
    constructor() {
        owner = msg.sender;
    }

    function isValidAnimalType(AnimalType _type) public pure returns (bool) {
        return (uint256(_type) <= uint256(AnimalType.Parrot));
    }

    function add(AnimalType _type, uint256 _count) public onlyOwner {
        if (!isValidAnimalType(_type)) {
            revert("Invalid animal");
        }
        _totalAnimals[_type] += _count;
        emit Added(_type, _count);
    }

    function borrow (uint _age, Gender _gender, AnimalType _type) public {
        //if (!isValidAnimalType(_type)) {
        //    revert("Invalid Animal");
        //}
        if (_age == 0) {
            revert("Invalid Age");
        }
        address borrower = msg.sender;

        // Zero is the default, can use "> 0" condition to see if ever set
        if (_borrowerAge[borrower] > 0 ) {
            if (_borrowerAge[borrower] != _age ) {
                // Returning user has changed their age
                revert("Invalid Age");
            }
            if (_borrowerGender[borrower] != _gender) {
                revert("genderfluid");
            }
        }
        else {
            // First time borrower, set age and gender
            _borrowerAge[borrower] = _age;
            _borrowerGender[borrower] = _gender;
        }

        // Can't borrow more than one animal at a time
        if (_borrows[borrower] != AnimalType.None) {
            revert("Already adopted a pet");
        }
        _borrows[borrower] = _type;

        // Can't borrow if no animal is available
        if (_totalAnimals[_type] == 0) {
            revert("Selected animal not available");
        }
        if (_totalAnimals[_type] - _borrowedAnimals[_type] == 0) {
            revert("all animals borrowed");
        }

        // Men can only borrow dogs and fish
        if (_gender == Gender.Male) {
            if ( ! ((_type == AnimalType.Dog) || (_type == AnimalType.Fish)) ) {
                revert("Selected animal not available");
            }
        }
        else { // assume Gender.Female
            if (_age < 40 && _type == AnimalType.Cat) {
                revert("no early cat ladies!");
            }
        }
        emit Borrowed(_type);
    }

    function giveBackAnimal() public {
        address borrower = msg.sender;
        AnimalType animalType = _borrows[borrower];
        if (animalType == AnimalType.None) {
            revert("No borrowed pets");
        }
        
        // Take care of return
        _borrows[borrower] = AnimalType.None;
        _borrowedAnimals[animalType]--;
        emit Returned(animalType);
    }

    function animalCounts (AnimalType _type)  public view returns (uint) {
        return _totalAnimals[_type];
    }
}
