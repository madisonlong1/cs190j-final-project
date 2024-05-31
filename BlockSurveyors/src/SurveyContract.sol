// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

//import {Survey} from "../src/Survey.sol";

//register function - address + custom username


contract SmartSurvey {
   
    //list of functions we must include:
    
    //view survey (surveyName); should allow the user to view a survey and all its details before deciding to participate

    struct registered_user{
        address userAddress;
        string username;
        uint password;
    }

    modifier onlyOwner {
        require(msg.sender == owner, 'call exclusive to owner');
        _;
    }
    
    // Mapping to a survey surveyName -> Survey
    mapping(string => Survey) private user_surveys; //name of survey maps to 

    // Event to be emitted when a new user registers
    event UserRegistered(string name, address userAddress);//do we need this line?

    // Mapping to store registered users for login
    mapping(address => registered_user) private users; //keep track of all registered users

    mapping(string => uint256) private balances; //bank for ether rewards, surveyName -> balance

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
    

    function vote(string memory _surveyName, uint256 option) public {
        require(user_surveys[_surveyName].hasVoted(msg.sender) == false, "User has already voted");
        require(user_surveys[_surveyName] != address(0), "Survey does not exist");//need to be fixed
        require(user_surveys[_surveyName].numAllowedResponses() > 0, "Survey is closed");
        require(option < user_surveys[_surveyName].solutions().length, "Invalid option");
        require(user_surveys[_surveyName].endTime() > block.timestamp, "Survey is closed");
        
        user_surveys[_surveyName].hasVoted[msg.sender] = true; //mark the user as having voted
        user_surveys[_surveyName].answers[option] += 1; //increment the number of votes for the option
        user_surveys[_surveyName].numAllowedResponces -= 1; //decrement the number of allowed responses remaining
        if (numAllowedResponces == 0) { //if the number of allowed responses is 0, close the survey
            user_surveys[_surveyName].endTime = block.timestamp;
        }
    }  

    function endNow(string _surveyName) public  {
        require(msg.sender == user_surveys[_surveyName].owner(), 'call exclusive to owner');
        user_surveys[_surveyName].numAllowedResponses = 0;
    }

    function sendReward() {
        //needs to be completed
    }

    function create_survey(string memory _surveyName, 
                          string memory _question, 
                          string[] memory _solutions, 
                          uint256 _duration, 
                          uint256 _numAllowedResponses) public payable {
        require(users[msg.sender].userAddress != address(0), "User not registered"); //make this function is exclusivly accessable to those who are registered already
        
        require(bytes(_surveyName).length > 0, "Survey name cannot be empty");
        require(bytes(_question).length > 0, "Question cannot be empty");
        require(_solutions.length > 0, "Solutions cannot be empty");
        require(_duration > 0, "Duration must be greater than 0");
        require(_numAllowedResponses > 0, "Number of allowed responses must be greater than 0");
        require(msg.value > 0, "Reward must be greater than 0");
        uint256[] memory ans;

        for (uint256 i = 0; i < _solutions.length; i++) { //initialize all answers to 0
            ans.push(0);
        }

        Survey memory s1 = Survey({
            surveyName: _surveyName,
            question: _question,
            solutions: _solutions,
            numAllowedResponses: _numAllowedResponses,
            startTime: block.timestamp,
            endTime: block.timestamp + _duration,
            ethReward: msg.value,
            answers: ans
        });
        
        user_surveys[_surveyName] = s1;
        balances[_surveyName] = msg.value;
    }

    function viewSurvey(string memory _surveyName) public {
        Survey survey = user_surveys[_surveyName];
        require(address(survey) != address(0), "Survey does not exist");//need to be fixed
       
        string memory surveyName = survey.surveyName;
        string memory question = survey.question;
        string[] memory solutions = survey.solutions;
        uint256 startTime = survey.startTime;
        uint256 endTime = survey.endTime;
        uint256 numAllowedResponses = survey.numAllowedResponses;

      
        emit SurveyDetails(_surveyName, question, solutions, startTime, endTime, numAllowedResponses); //print the  information for the user      
    }    



     
//////////////////////////////////////////////////////// Survey structure
    struct Survey {
        
        address owner;
        uint256 id;
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
    //////////////////////////////////////////////////////////////// End Survey structure
    

    
  
}