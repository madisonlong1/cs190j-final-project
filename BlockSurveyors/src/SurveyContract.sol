// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

//import {Survey} from "../src/Survey.sol";

//register function - address + custom username


contract SmartSurvey {
   
    struct registered_user{
        address userAddress;
        string username;
        uint password;
    }

    struct Survey {
        
        address owner;
        //uint256 id;
        mapping (address => bool) hasVoted; //mapping of addresses to whether or not they have voted true or false
        string surveyName; // name of the survey
        string question; // the question the user asks
        string[] solutions; // Written multiple choice options
        uint256[] answers; // collect answers
        uint256 numAllowedResponses; // how many people have answered
        uint256 startTime; // when the survey opens
        uint256 endTime; // when the survey closes
        uint256 ethReward; // amount of reward given to users
    }
    // modifier onlyOwner {
    //     require(msg.sender == owner, 'call exclusive to owner');
    //     _;
    // }
    
    // Mapping to a survey surveyName -> Survey
    mapping(string => Survey) private user_surveys; 

    

    // Mapping to store registered users for login
    mapping(address => registered_user) private users; //keep track of all registered users

    mapping(string => uint256) private balances; //bank for ether rewards, surveyName -> balance

    //events
    event UserRegistered(string name, address userAddress); // Event to be emitted when a new user registers
    event SurveyDetails( // Event to log survey details (simulating print)
        string surveyName,
        string question,
        string[] solutions,
        uint256 startTime,
        uint256 endTime,
        uint256 numAllowedResponses,
        uint256 ethReward
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

    function getUser(address userAddress) public view returns (address, string memory, uint256) {
        registered_user memory user = users[userAddress];
        return (user.userAddress, user.username, user.password);
    } 
    

    function vote(string memory _surveyName, uint256 option) public {
        Survey storage thisSurvey = user_surveys[_surveyName];
        
        require(!thisSurvey.hasVoted[msg.sender], "User has already voted");
        require(thisSurvey.owner != address(0), "Survey does not exist");//need to be fixed
        require(thisSurvey.numAllowedResponses > 0, "Survey is closed");
        require(option < thisSurvey.solutions.length, "Invalid option");
        require(thisSurvey.endTime > block.timestamp, "Survey is closed");
        
        thisSurvey.hasVoted[msg.sender] = true; //mark the user as having voted
        thisSurvey.answers[option] += 1; //increment the number of votes for the option
        thisSurvey.numAllowedResponses = thisSurvey.numAllowedResponses + 1;//decrement the number of allowed responses remaining
        
        if (thisSurvey.numAllowedResponses == 0) { //if the number of allowed responses is 0, close the survey
            thisSurvey.endTime = block.timestamp;
        }
    }  

    function endNow(string memory _surveyName) public  {
        Survey storage thisSurvey = user_surveys[_surveyName];
        require(msg.sender == thisSurvey.owner, 'only the owner can end a survey early');
        thisSurvey.numAllowedResponses = 0;
        thisSurvey.endTime = block.timestamp;
    }


    function create_survey(
                          string memory _surveyName, 
                          string memory _question, 
                          string[] memory _solutions, 
                          uint256 _duration, 
                          uint256 _numAllowedResponses) 
        public payable {
        require(users[msg.sender].userAddress != address(0), "User not registered"); //make this function is exclusivly accessable to those who are registered already
        
        require(bytes(_surveyName).length > 0, "Survey name cannot be empty");
        require(bytes(_question).length > 0, "Question cannot be empty");
        require(_solutions.length > 0, "Solutions cannot be empty");
        require(_duration > 0, "Duration must be greater than 0");
        require(_numAllowedResponses > 0, "Number of allowed responses must be greater than 0");
        require(msg.value > 0, "Reward must be greater than 0");

        //uint256[] memory ans;
        // for (uint256 i = 0; i < _solutions.length; i++) { //initialize all answers to 0
        //     ans.push(0);
        // }
        Survey storage thisSurvey = user_surveys[_surveyName];
      
        thisSurvey.owner = msg.sender;
        thisSurvey.surveyName = _surveyName;
        thisSurvey.question = _question;
        thisSurvey.solutions = _solutions;
        thisSurvey.answers = new uint256[](_solutions.length);
        thisSurvey.numAllowedResponses = _numAllowedResponses;
        thisSurvey.startTime = block.timestamp;
        thisSurvey.endTime = block.timestamp + _duration;
        thisSurvey.ethReward = msg.value;
        
        balances[_surveyName] = msg.value;
    }

    function viewSurvey(string memory _surveyName) public {
        Survey storage thisSurvey = user_surveys[_surveyName];
        require(thisSurvey.owner != address(0), "Survey does not exist");//need to be fixed
       
        emit SurveyDetails(
                            thisSurvey.surveyName, 
                            thisSurvey.question, 
                            thisSurvey.solutions, 
                            thisSurvey.numAllowedResponses,
                            thisSurvey.startTime, 
                            thisSurvey.endTime, 
                            thisSurvey.ethReward
                            );   
    }

    //function to return the values of a 
    function getSurvey(string memory _surveyName) public view returns 
    (address, string memory, string memory, string[] memory,uint256[] memory, uint256, uint256, uint256, uint256) {
        Survey storage thisSurvey = user_surveys[_surveyName];
        require(thisSurvey.owner != address(0), "Survey does not exist");
        return (thisSurvey.owner, 
                thisSurvey.surveyName, 
                thisSurvey.question,
                thisSurvey.solutions, 
                thisSurvey.answers,
                thisSurvey.numAllowedResponses,
                thisSurvey.startTime, 
                thisSurvey.endTime,  
                thisSurvey.ethReward
                );
    }

    // function sendReward() {
    //     //needs to be completed
    // }

     
//////////////////////////////////////////////////////// Survey structure
    
    //////////////////////////////////////////////////////////////// End Survey structure

  
}