// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

//register function - address + custom username

//data struct for Survey

//data struct for user

contract SmartSurvey {
   
    


    modifier onlyOwner {
        require(msg.sender == owner, 'call exclusive to owner');
    }

    struct registered_user {
        address userAddress;
        string username;
        uint password;
    }

    struct survey {
        //address private owner;
        uint256 id;
        registered_user user; // name of registered_user
        string problem; // the question the user asks
        string[] solutions; // Written multiple choice options
        uint256[] answers; // collect answers
        uint256 numAllowedResponces; // how many people have answered
        uint256 startTime; // when the survey opens
        uint256 endTime; // when the survey closes
        // uint256 ethReward; // amount of reward given to users?

        //constructor() {
        //    owner = msg.sender;
        //} 
    }


    // Mapping to store registered users for login
    mapping(address => registered_user) private users;

    // Mapping to a survey (list?)
    mapping(address => uint256) private user_surveys;

    // Event to be emitted when a new user registers
    event UserRegistered(string name, address userAddress);

    function registerUser(string memory _username, uint256 _password) public {
        require(users[msg.sender].userAddress == address(0), "User already registered");
        require(bytes(_username).length > 0, "Username cannot be empty");
        users[msg.sender] = registered_user(msg.sender, _username, _password);
        emit UserRegistered(_username, msg.sender);
    }
    
    //should this function be payable?
    function create_survey(string memory problems) public {
        // if 
    }
    
    function vote(uint256 survey_id, unit option) public {
        
    }
    
    function login() public {
        
    }

    function get_result(uint256 survey_id) public {
        
    }


    constructor() {
        owner = msg.sender;
    }   

}