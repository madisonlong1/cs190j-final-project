// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Survey} from "../src/Survey.sol";

//register function - address + custom username


contract SmartSurvey {
   
    //list of functions we must include:
    
    //view survey (surveyName); should allow the user to view a survey and all its details before deciding to participate

    struct registered_user{
        address userAddress;
        string username;
        uint password;
    }

    // Mapping to a survey (list?)
    mapping(string => Survey) private user_surveys; //name of survey maps to 

    // Event to be emitted when a new user registers
    event UserRegistered(string name, address userAddress);

    // Mapping to store registered users for login
    mapping(address => registered_user) private users; //keep track of all registered users

    // Event to log survey details (simulating print)
    event SurveyDetails(
        string surveyName,
        string question,
        string[] solutions,
        uint256 startTime,
        uint256 endTime,
        uint256 numAllowedResponses
    );
   
    function registerUser(string memory _username, uint256 _password) public {
        require(users[msg.sender].userAddress == address(0), "User already registered"); // make sure user is not already registered
        require(bytes(_username).length > 0, "Username cannot be empty"); // make sure username is not empty
    
        registered_user memory User = registered_user({ //define an instance of the registered user struct
            userAddress: msg.sender,
            username: _username,
            password: _password
        });
        
        users[msg.sender] = User; //map users address to their struct
        emit UserRegistered(_username, msg.sender);
    }

    
    function create_survey(string memory _surveyName, 
                          string memory _question, 
                          string[] memory _solutions, 
                          uint256 _duration, 
                          uint256 _numAllowedResponces) public payable {
        require(users[msg.sender].userAddress != address(0), "User not registered"); //make this function is exclusivly accessable to those who are registered already
        
        require(bytes(_surveyName).length > 0, "Survey name cannot be empty");
        require(bytes(_question).length > 0, "Question cannot be empty");
        require(_solutions.length > 0, "Solutions cannot be empty");
        require(_duration > 0, "Duration must be greater than 0");
        require(_numAllowedResponces > 0, "Number of allowed responses must be greater than 0");
        require(msg.value > 0, "Reward must be greater than 0");

        Survey survey = new Survey{value: msg.value}(_surveyName, _question, _solutions, _duration, _numAllowedResponces);
        user_surveys[_surveyName] = survey;
    }

    function viewSurvey(string memory _surveyName) public {
        Survey survey = user_surveys[_surveyName];
        require(address(survey) != address(0), "Survey does not exist");

        string memory surveyName = survey.surveyName();
        string memory question = survey.question();
        string[] memory solutions = survey.solutions();
        uint256 startTime = survey.startTime();
        uint256 endTime = survey.endTime();
        uint256 numAllowedResponses = survey.numAllowedResponces();

        emit SurveyDetails(surveyName, question, solutions, startTime, endTime, numAllowedResponses); //print the  information for the user 
    }
    
    function vote(string memory _surveyName, uint256 option) public {
        require(user_surveys[_surveyName].hasVoted[msg.sender] == false, "User has already voted");
        require(user_surveys[_surveyName] != address(0), "Survey does not exist");
        require(user_surveys[_surveyName].numAllowedResponces() > 0, "Survey is full");
        require(option < user_surveys[_surveyName].solutions().length, "Invalid option");
        require(user_surveys[_surveyName].endTime() > block.timestamp, "Survey is closed");
        

        user_surveys[_surveyName].vote(option);
    }  


    


     

}