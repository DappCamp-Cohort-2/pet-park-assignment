//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "hardhat/console.sol";

contract PetPark {

    event Added(uint8 animal_type, uint count);
    event Borrowed(uint8 animaltype);
    event Returned(uint8 animaltype);

    struct borrowingDetail{
        uint8 animalType;
        uint8 age;
        bool borrowed;
        uint8 gender;
    }
    address owner;

    mapping(uint8=>uint) public animalCounts;
    mapping(address=>borrowingDetail) hasBorrowed;
    mapping (address => bool) userExists;
 

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender==owner,"Not an owner");
        _;
    }



    modifier checkUser(uint8 age,uint8 gender){
        require(age>0,"Invalid Age");
        require(gender==0 || gender==1, "Invalid Gender");
        if(!userExists[msg.sender]){
            userExists[msg.sender]=true;
            hasBorrowed[msg.sender].age=age;
            hasBorrowed[msg.sender].gender=gender;
        }
        require(hasBorrowed[msg.sender].age == age,"Invalid Age");
        require(hasBorrowed[msg.sender].gender==gender, "Invalid Gender");
        require(!hasBorrowed[msg.sender].borrowed,"Already adopted a pet");
        _;
    }

    function add(uint8 animal_type, uint8 count) external onlyOwner  {
        require(animal_type>0 && animal_type<=5,"Invalid animal");
        animalCounts[animal_type]+=count;
        emit Added(animal_type, count);
    }

    function borrow(uint8 age, uint8 gender, uint8 animal_type) external checkUser(age, gender) {
        
        require(animal_type>0 && animal_type<=5,"Invalid animal type");
        require(animalCounts[animal_type]>0,"Selected animal not available");
        if(gender==0){
            require(animal_type==1 || animal_type==3,"Invalid animal for men");
        }
        else if (gender == 1 && age < 40) {
            require(animal_type != 2, "Invalid animal for women under 40");
        }

        hasBorrowed[msg.sender].animalType=animal_type;
        hasBorrowed[msg.sender].borrowed=true;
        hasBorrowed[msg.sender].age=age;
        hasBorrowed[msg.sender].gender=gender;

        animalCounts[animal_type]--;

        emit Borrowed(animal_type);
    } 

    function giveBackAnimal() external{
        require(hasBorrowed[msg.sender].borrowed,"No borrowed pets");
        uint8 animal_type = hasBorrowed[msg.sender].animalType;
        animalCounts[animal_type]++;

        hasBorrowed[msg.sender].borrowed == false;
        emit Returned(animal_type);
    }

}