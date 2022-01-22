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

    struct Borrow {
        AnimalType species;
        Gender  gender;
        uint256 age;
    }

    mapping (AnimalType => uint256) private _totalAnimals;
    mapping (AnimalType => uint256) private _borrowedAnimals; // Count

    mapping (address => Borrow) private _borrows;

    // Constructor: save owner for later
    constructor() {
        owner = msg.sender;
    }

    function isValidAnimalType(AnimalType _type) public pure returns (bool) {
        return ( (uint256(_type) <= uint256(AnimalType.Parrot) )
              && (uint256(_type) >  uint256(AnimalType.None  ) ) );
    }

    function add(AnimalType _type, uint256 _count) external onlyOwner {
        if (!isValidAnimalType(_type)) {
            revert("Invalid animal");
        }
        _totalAnimals[_type] += _count;
        emit Added(_type, _count);
    }

    function borrow (uint _age, Gender _gender, AnimalType _type) public {
        if (!isValidAnimalType(_type)) {
            revert("Invalid animal type");
        }
        if (_age == 0) {
            revert("Invalid Age");
        }
        address borrower = msg.sender;

        // Zero is the default, can use "> 0" condition to see if ever set
        if (_borrows[borrower].age > 0 ) {
            if (_borrows[borrower].age != _age ) {
                // Returning user has changed their age
                revert("Invalid Age");
            }
            if (_borrows[borrower].gender != _gender) {
                revert("Invalid Gender");
            }
        }
        else {
            // First time borrower, set age and gender
            _borrows[borrower].age = _age;
            _borrows[borrower].gender = _gender;
        }

        // Can't borrow more than one animal at a time
        if  (_borrows[borrower].species != AnimalType.None) {
            revert("Already adopted a pet");
        }

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
                revert("Invalid animal for men");
            }
        }
        else { // assume Gender.Female
            if (_age < 40 && _type == AnimalType.Cat) {
                revert("Invalid animal for women under 40");
            }
        }

        _borrowedAnimals[_type]++;
        _borrows[borrower].species = _type;

        emit Borrowed(_type);
    }

    function giveBackAnimal() public {
        address borrower = msg.sender;
        AnimalType animalType = _borrows[borrower].species;
        if (animalType == AnimalType.None) {
            revert("No borrowed pets");
        }
        
        // Take care of return
        _borrows[borrower].species = AnimalType.None;
        _borrowedAnimals[animalType]--;
        emit Returned(animalType);
    }

    function animalCounts (AnimalType _type)  public view returns (uint) {
        return _totalAnimals[_type] - _borrowedAnimals[_type];
    }
}
