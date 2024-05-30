// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Survey} from "../src/Survey.sol";

//register function - address + custom username


contract SmartSurvey {
   
    //list of functions we must include:
    //register
    //create survey   (surveyName, surveyDescription, surveyOptions, surveyDuration, surveyReward);
    //view survey (surveyName);

    struct registered_user{
        address userAddress;
        string username;
        uint password;
    }

    // Mapping to store registered users for login
    mapping(address => registered_user) private users;
   
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



    // Mapping to a survey (list?)
    mapping(address => uint256) private user_surveys;

    // Event to be emitted when a new user registers
    event UserRegistered(string name, address userAddress);

    
    //should this function be payable?
    function create_survey(string memory problems) public {
        
    }
    
    function vote(uint256 survey_id, uint256 option) public {
        
    }
    


    function get_result(uint256 survey_id) public {
        
    }


    constructor() {
        owner = msg.sender;
    }   

}