//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    enum AnimalType { None, Fish, Cat, Dog, Rabbit, Parrot }
    enum Gender { Male, Female }

    struct Customer {
        uint8 age;
        Gender gender;
        AnimalType borrowed;
    }

    event Added(AnimalType animalType, uint count);
    event Borrowed(AnimalType animalType);
    event Returned(AnimalType animalType);

    address owner;

    mapping(AnimalType => uint) animalsInPark;
    mapping(address => Customer) customers;

    modifier isOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function _isValidAnimalType(AnimalType _animalType) private pure returns (bool) {
        return _animalType >= AnimalType.Fish && _animalType <= AnimalType.Parrot;
    }

    function _isReturningCustomer(address _address) private view returns (bool) {
        return customers[_address].age != 0;
    }

    function add(AnimalType _animalType, uint _count) external isOwner() {
        require(_isValidAnimalType(_animalType), "Invalid animal type");

        animalsInPark[_animalType] += _count;

        emit Added(_animalType, _count);
    }

    function borrow(uint8 _age, Gender _gender, AnimalType _animalType) external {
        require(_age > 0, "Invalid Age");
        require(_isValidAnimalType(_animalType), "Invalid animal type");
        require(animalsInPark[_animalType] > 0, "Selected animal not available");

        if(_isReturningCustomer(msg.sender)) {
            require(_age == customers[msg.sender].age, "Invalid Age");
            require(_gender == customers[msg.sender].gender, "Invalid Gender");
            require(customers[msg.sender].borrowed == AnimalType.None, "Already adopted a pet");
        }

        if(_gender == Gender.Male) {
            require(_animalType == AnimalType.Fish || _animalType == AnimalType.Dog, "Invalid animal for men");
        } else if(_age < 40) {
            require(_animalType != AnimalType.Cat, "Invalid animal for women under 40");
        }

        customers[msg.sender] = Customer(_age, _gender, _animalType);
        animalsInPark[_animalType] -= 1;

        emit Borrowed(_animalType);
    }

    function animalCounts(AnimalType _animalType) external view returns (uint) {
        return animalsInPark[_animalType];
    }

    function giveBackAnimal() external {
        require(_isReturningCustomer(msg.sender) && customers[msg.sender].borrowed != AnimalType.None, "No borrowed pets");

        AnimalType _borrowedAnimal = customers[msg.sender].borrowed;
        animalsInPark[_borrowedAnimal] += 1;
        customers[msg.sender].borrowed = AnimalType.None;

        emit Returned(_borrowedAnimal);
    }
}