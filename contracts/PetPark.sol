//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract PetPark {
    address owner;

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

    struct PetOwnerDetails {
        Gender gender;
        uint8 age;
        address petOwnerAddress;
        AnimalType pet;
    }

    mapping(uint8 => uint256) private shelter;
    mapping(address => PetOwnerDetails) private petOwners;

    event Added(AnimalType animalType, uint256 count);
    event Borrowed(AnimalType animalType);

    constructor() {
        owner = msg.sender;
    }

    function add(uint8 animalType, uint256 count) external {
        require(msg.sender == owner, "Not an owner");
        require(animalType >= 1 && animalType <= 5, "Invalid animal");
        shelter[animalType] += count;
        emit Added(AnimalType(animalType), count);
    }

    function borrow(
        uint8 age,
        uint8 gender,
        uint8 animalType
    ) external {
        require(age > 0, "Invalid Age");
        require(
            animalType > uint8(AnimalType.None) &&
                animalType <= uint8(AnimalType.Parrot),
            "Invalid animal type"
        );
        require(shelter[animalType] > 0, "Selected animal not available");
        PetOwnerDetails storage petOwner = petOwners[msg.sender];

        if (petOwner.petOwnerAddress != address(0)) {
            require(petOwner.age == age, "Invalid Age");
            require(uint8(petOwner.gender) == gender, "Invalid Gender");
            revert("Already adopted a pet ");
        }

        if (
            gender == uint8(Gender.Male) &&
            (animalType != uint8(AnimalType.Fish) &&
                animalType != uint8(AnimalType.Dog))
        ) {
            revert("Invalid animal for men");
        }

        if (
            gender == uint8(Gender.Female) &&
            age < 40 &&
            animalType == uint8(AnimalType.Cat)
        ) {
            revert("Invalid animal for women under 40");
        }

        petOwners[msg.sender] = PetOwnerDetails(
            Gender(gender),
            age,
            msg.sender,
            AnimalType(animalType)
        );
        shelter[animalType]--;
        emit Borrowed(AnimalType(animalType));
    }

    function animalCounts(uint8 animalType) external view returns (uint256) {
        return shelter[animalType];
    }

    function giveBackAnimal() external {
        PetOwnerDetails memory petOwnerDetails=petOwners[msg.sender];
        require(
            petOwnerDetails.petOwnerAddress != address(0),
            "No borrowed pets"
        );
        shelter[uint8(petOwnerDetails.pet)]++;
        delete petOwners[msg.sender];

    }
}
