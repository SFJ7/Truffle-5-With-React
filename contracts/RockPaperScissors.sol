pragma solidity >=0.5.0 <0.6.0;

import "./Ownable.sol";

contract RockPaperScissors is Ownable {
    //Constructor
    constructor() public {
        owner = msg.sender;
    }

    //modifier
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    //deactivate the contract
//    function kill() public onlyOwner {
//        selfdestruct(owner);
//    }

    //Types for the Challenge
    struct Challenge {
        uint id;
        address payable challengeCreator;
        address payable challenger;
        string challengeCreatorChoice;
        string challengerChoice;
        address winner;
        uint256 price;
    }

    //state variables
    address owner;
    mapping(uint => Challenge) public challenges;
    uint challengeCounter;

    //events
    event LogPostChallenge(
        uint indexed _id,
        address indexed _challengeCreator,
        uint256 _price
    );

    event LogChallenge(
        uint indexed _id,
        address indexed _challengeCreator,
        address indexed _challenger,
        string _challengerChoice,
        string _challengeCreatorChoice,
        address _winner,
        uint256 _price
    );

    //create a challenge
    function createChallenge(string memory _choice, uint256 _price) public {
        //new challenge
        challengeCounter++;

        //store the challenge
        challenges[challengeCounter] = Challenge(
            challengeCounter,
            msg.sender,
            address(0),
            _choice,
            ' ',
            address(0),
            _price
        );

        emit LogPostChallenge(challengeCounter, msg.sender, _price);
    }

    //fetch number of challenges in the contract
    function getNumberOfChallenges() public view returns (uint) {
        return challengeCounter;
    }

    //fetch and return all challenge ids that are still available
    function getChallengesStillAvailable() public view returns (uint[] memory) {
        uint[] memory challengeIds = new uint[](challengeCounter);

        uint numberOfChallengesAvailable = 0;

        for (uint i = 1; i <= challengeCounter; i++) {
            //keep id if still up for a challenge
            if (challenges[i].challenger == address(0)) {
                challengeIds[numberOfChallengesAvailable] = challenges[i].id;
                numberOfChallengesAvailable++;
            }
        }

        //copy all the challenges into a smaller array
        uint[] memory upForChallenge = new uint[](numberOfChallengesAvailable);

        for (uint j = 0; j<numberOfChallengesAvailable; j++) {
            upForChallenge[j] = challengeIds[j];
        }

        return upForChallenge;
    }

    //accept a challenge
    function acceptChallenge(uint _id, string memory _choice) public payable {
        //check whether there is at least one challenge
        require(challengeCounter > 0, "There should be at least 1 challenge");

        //check whether the challenge exists
        require(_id > 0 && _id <= challengeCounter, "Article with this id does not exist");

        //retrieve the challenge
        Challenge storage challenge = challenges[_id];

        //check whether the challenge has already been completed
        require(challenge.challenger == address(0), "Someone has already won this challenge");

        //check whether the value sent corresponds to the value of the challenge
        require(challenge.price == msg.value, "Value provided does not match the challenge");

        //check if the challenger is trying to challenge themselves
        require(challenge.challengeCreator != msg.sender, "Challenger cannot challenge themselves");

        //save the challenger's choice
        challenge.challengerChoice = _choice;

        //save the challenger
        challenge.challenger = msg.sender;

        //check who won, ties will keep the address 0 as winner
        address winner = address(0);

        //challenge creator won, send winning to challenger
        if (keccak256(abi.encodePacked(challenge.challengeCreatorChoice)) == keccak256(abi.encodePacked('rock')) && keccak256(abi.encodePacked(_choice)) == keccak256(abi.encodePacked('scissors'))) {
            challenge.challengeCreator.transfer(msg.value);
            winner = challenge.challengeCreator;

        }

        if (keccak256(abi.encodePacked(challenge.challengeCreatorChoice)) == keccak256(abi.encodePacked('scissors')) && keccak256(abi.encodePacked(_choice)) == keccak256(abi.encodePacked('paper'))) {
            challenge.challengeCreator.transfer(msg.value);
            winner = challenge.challengeCreator;
        }

        if (keccak256(abi.encodePacked(challenge.challengeCreatorChoice)) == keccak256(abi.encodePacked('paper')) && keccak256(abi.encodePacked(_choice)) == keccak256(abi.encodePacked('rock'))) {
            challenge.challengeCreator.transfer(msg.value);
            winner = challenge.challengeCreator;
        }

        //challenger won, send winnings to challenge
        if (keccak256(abi.encodePacked(challenge.challengeCreatorChoice)) == keccak256(abi.encodePacked('rock')) && keccak256(abi.encodePacked(_choice)) == keccak256(abi.encodePacked('paper'))) {
            msg.sender.transfer(msg.value);
            winner = msg.sender;
        }

        if (keccak256(abi.encodePacked(challenge.challengeCreatorChoice)) == keccak256(abi.encodePacked('scissors')) && keccak256(abi.encodePacked(_choice)) == keccak256(abi.encodePacked('rock'))) {
            msg.sender.transfer(msg.value);
            winner = msg.sender;
        }

        if (keccak256(abi.encodePacked(challenge.challengeCreatorChoice)) == keccak256(abi.encodePacked('paper')) && keccak256(abi.encodePacked(_choice)) == keccak256(abi.encodePacked('scissors'))) {
            msg.sender.transfer(msg.value);
            winner = msg.sender;
        }

    emit LogChallenge(_id, challenge.challengeCreator, msg.sender, _choice, challenge.challengeCreatorChoice, winner, challenge.price);
    }

}