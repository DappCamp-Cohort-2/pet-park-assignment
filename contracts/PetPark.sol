// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "hardhat/console.sol";

contract PetPark {
    address private owner;
    /**
    Main data types
    1/ Enums for animals and gender
    2/ Struct for borrowers 
    **/
    enum Animals {
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

    struct Borrowers {
        uint256 age;
        Gender gender;
        Animals animalBorrowed;
    }

    // Mapping
    /**
    There are two main mappings
        - First is to map addresses interacting with contract with the borrowers struct
        - Second is to map the animalTypes with the number of times it is in the park
    **/

    mapping(address => Borrowers) borrowers;
    mapping(Animals => uint256) public parkAnimalCount;

    // Events
    event Added(Animals animal, uint256 animalCount);
    event Borrowed(Animals animal);
    event Returned(Animals animal);

    // Constructor initialized
    constructor() {
        owner = msg.sender;
    }

    // Modifiers
    /**
        1. First modifier ensures that only owner operates
        2. Second modifier ensures valid numbers are only passed through
    **/

    modifier isOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    modifier animalValidityCheck(Animals _animal) {
        require(_animal != Animals.None, "Invalid animal type");
        _;
    }

    function add(Animals _animal, uint256 _count)
        public
        isOwner
        animalValidityCheck(_animal)
    {
        require(_animal != Animals.None, "Invalid animal type");
        parkAnimalCount[_animal] = _count;

        emit Added(_animal, _count);
    }

    function borrow(
        uint256 _age,
        Gender _gender,
        Animals _animal
    ) public {
        // Check if age is a real number
        if (_age == 0) {
            revert("Invalid Age");
        }

        // Check to ensure they have not already borrowed an animal
        require(
            borrowers[owner].animalBorrowed == Animals.None,
            "Already adopted a pet"
        );

        //Check to ensure that they are not changing their information
        if (borrowers[owner].age != 0) {
            require(borrowers[owner].age == _age, "Invalid Age");
            require(borrowers[owner].gender == _gender, "Invalid Gender");
        }

        // Check to ensure animal is available
        require(parkAnimalCount[_animal] > 0, "Selected animal not available");

        // Check to see if the animal number is valid
        if (_animal == Animals.None) {
            revert("Invalid animal type");
        }

        // Check to see if a man is borrowing
        if (_gender == Gender.Male) {
            require(
                _animal == Animals.Dog || _animal == Animals.Fish,
                "Invalid animal for men"
            );
        }
        // Checking to see if woman < 40 and borrowing not a cat
        if (_gender == Gender.Female && _age < 40) {
            require(
                _animal != Animals.Cat,
                "Invalid animal for women under 40"
            );
        }

        // Let them borrow
        parkAnimalCount[_animal] -= 1;
        borrowers[owner] = Borrowers({
            age: _age,
            gender: _gender,
            animalBorrowed: _animal
        });

        // Emit event Borrowed
        emit Borrowed(_animal);
    }

    function giveBackAnimal(Animals _animal) public isOwner {
        require(
            borrowers[owner].animalBorrowed != Animals.None,
            "No borrowed pets"
        );
        parkAnimalCount[_animal] += 1;
        borrowers[owner].animalBorrowed = Animals.None;
    }
}
