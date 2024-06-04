// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract SmartSurvey {
    struct RegisteredUser {
        address userAddress;
        string username;
        uint256 password;
    }

    struct Survey {
        address owner;
        string surveyName;
        string question;
        string[] solutions;
        uint256[] answers;
        uint256 numAllowedResponses;
        uint256 startTime;
        uint256 endTime;
        uint256 ethReward;
        mapping(address => bool) hasVoted;
    }

    mapping(string => Survey) private userSurveys; // Mapping surveyName to Survey
    mapping(address => RegisteredUser) private users; // Mapping to store registered users
    mapping(string => uint256) private balances; // Bank for ether rewards

    event UserRegistered(string username, address userAddress);
    event SurveyDetails(
        string surveyName,
        string question,
        string[] solutions,
        uint256 startTime,
        uint256 endTime,
        uint256 numAllowedResponses
    );

    function registerUser(string memory _username, uint256 _password) public {
        require(users[msg.sender].userAddress == address(0), "User already registered");
        require(bytes(_username).length > 0, "Username cannot be empty");

        RegisteredUser memory newUser = RegisteredUser({
            userAddress: msg.sender,
            username: _username,
            password: _password
        });

        users[msg.sender] = newUser;
        emit UserRegistered(_username, msg.sender);
    }

    function getUser(address userAddress) public view returns (address, string memory, uint256) {
        RegisteredUser memory user = users[userAddress];
        return (user.userAddress, user.username, user.password);
    }

    function vote(string memory _surveyName, uint256 option) public {
        Survey storage survey = userSurveys[_surveyName];

        require(survey.owner != address(0), "Survey does not exist");
        require(!survey.hasVoted[msg.sender], "User has already voted");
        require(survey.numAllowedResponses > 0, "Survey is closed");
        require(option < survey.solutions.length, "Invalid option");
        require(survey.endTime > block.timestamp, "Survey is closed");

        survey.hasVoted[msg.sender] = true;
        survey.answers[option] += 1;
        survey.numAllowedResponses -= 1;

        if (survey.numAllowedResponses == 0) {
            survey.endTime = block.timestamp;
        }
    }

    function endNow(string memory _surveyName) public {
        Survey storage survey = userSurveys[_surveyName];
        require(msg.sender == survey.owner, "Only the survey owner can end it");

        survey.numAllowedResponses = 0;
        survey.endTime = block.timestamp;
    }

    function createSurvey(
        string memory _surveyName,
        string memory _question,
        string[] memory _solutions,
        uint256 _duration,
        uint256 _numAllowedResponses
    ) public payable {
        require(users[msg.sender].userAddress != address(0), "User not registered");
        require(bytes(_surveyName).length > 0, "Survey name cannot be empty");
        require(bytes(_question).length > 0, "Question cannot be empty");
        require(_solutions.length > 0, "Solutions cannot be empty");
        require(_duration > 0, "Duration must be greater than 0");
        require(_numAllowedResponses > 0, "Number of allowed responses must be greater than 0");
        require(msg.value > 0, "Reward must be greater than 0");

        Survey storage survey = userSurveys[_surveyName];
        survey.owner = msg.sender;
        survey.surveyName = _surveyName;
        survey.question = _question;
        survey.solutions = _solutions;
        survey.answers = new uint256[](_solutions.length);
        survey.numAllowedResponses = _numAllowedResponses;
        survey.startTime = block.timestamp;
        survey.endTime = block.timestamp + _duration;
        survey.ethReward = msg.value;

        balances[_surveyName] = msg.value;
    }

    function getSurvey(string memory _surveyName) public view returns (
        address, string memory, string memory, string[] memory, uint256[] memory, uint256, uint256, uint256, uint256
    ) {
        Survey storage survey = userSurveys[_surveyName];
        return (
            survey.owner,
            survey.surveyName,
            survey.question,
            survey.solutions,
            survey.answers,
            survey.numAllowedResponses,
            survey.startTime,
            survey.endTime,
            survey.ethReward
        );
    }

    function viewSurvey(string memory _surveyName) public {
        Survey storage survey = userSurveys[_surveyName];
        require(survey.owner != address(0), "Survey does not exist");

        emit SurveyDetails(
            survey.surveyName,
            survey.question,
            survey.solutions,
            survey.startTime,
            survey.endTime,
            survey.numAllowedResponses
        );
    }
}
