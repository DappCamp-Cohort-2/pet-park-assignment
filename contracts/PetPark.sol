//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


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
  struct Customer {
    Gender gender;
    uint age;
    AnimalType borrowedAnimal;
    bool hasBorrowedBefore;
  }
  address public owner;
  mapping (AnimalType => uint) animalCount;
  mapping (address => Customer) customerAnimals;

  constructor (){
    owner = msg.sender;
  }

  event Added(
      uint animalType,
      uint Count
    );
  event Borrowed(
    uint animalType
    );
  event Returned(
    uint animalType
    );
  function add (AnimalType animalType, uint256 count) public {
    require(msg.sender == owner, 'Not an owner');
    require (animalType != AnimalType.None, "Invalid animal");
    animalCount[(animalType)]+=count;
    emit Added(uint(animalType), count);
  }

  function borrow(uint _age, Gender _gender, AnimalType _animalType)
  public
  checkAllownace(_animalType, _gender, _age)
  {
    Customer storage customer = customerAnimals[msg.sender];
    customer.hasBorrowedBefore=true;
    customer.age=_age;
    customer.gender = _gender;
    animalCount[(_animalType)]--;
    emit Borrowed(uint(_animalType));
  }
  function giveBackAnimal(AnimalType animalType) public {
   require(customerAnimals[msg.sender].borrowedAnimal!= AnimalType.None, "No borrowed pets" );
   customerAnimals[msg.sender].borrowedAnimal = AnimalType.None;
   animalCount[(animalType)]++;
   emit Returned (uint(animalType));
  }

  modifier checkAllownace(AnimalType _animalType, Gender _gender,uint _age) {
    Customer storage customer = customerAnimals[msg.sender];
    require(customer.borrowedAnimal==AnimalType.None, "Already adopted a pet");
    require(_animalType!= AnimalType.None , 'Invalid Animal Type');
    require(_age > 0, "Invalid Age");
    require(animalCount[_animalType]>0,"Selected animal not available");
    if (customer.hasBorrowedBefore == true){
      require(customer.gender == _gender ,"Invalid Gender");
      require(customer.age == _age, "Invalid Age");
    }
    if (_gender == Gender.Male){
      require(_animalType == AnimalType.Dog || _animalType == AnimalType.Fish, 'Invalid animal for men');
    }
    if(_gender == Gender.Female){
      if(_age<40){
        require(_animalType!= AnimalType.Cat, 'Invalid animal for women under 40');
      }
    }
    _;
  }

}
