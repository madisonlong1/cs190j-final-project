# BlockSurveyors
## Team Name: Mind-Blockers
### Team Members: Shuyi Wan, Yicong Yan, Madison Long, Jason Vu

## Overview of the System:
The blockchain survey system is designed to enable users to create and participate in single-choice surveys, where each survey consists of a question with multiple integer-based options. The system includes functionalities for user registration, survey creation, participation, and automatic or manual survey closure with reward distribution.

## Setup and Initialization Instruction
[Check the README](https://github.com/madisonlong1/cs190j-final-project/blob/main/BlockSurveyors/README.md)

## APIs
+ Sign up
```
registerUser(string memory _username, uint256 _password) 
```
Call this function with your username and password to register. Only registered user can create a survey.
Example: ``` registerUser("username", 1234); ```
---

+ Vote in a survey
```
vote(string memory _surveyName, uint256 option)
```
Vote for a certain survey using its name.
Example:
```
vote("Survey 1", 1)  
```      
---

+ End the survey as the owner
```
endByOwner(string memory _surveyName)
```
End a certain survey using its name. Only the owner can do that, else return an error.

Example: 
```
endByOwner("Survey 1");
```
---

+ Create a survey
```
    function create_survey(
                          string memory _surveyName, 
                          string memory _question, 
                          string[] memory _solutions, 
                          uint256 _duration, 
                          uint256 _numAllowedResponses,
                          uint256 _password)
```
Create a survey by entering its required parameters.
Example:   
```
          string[] memory options = new string[](3);
          options[0] = "red";
          options[1] = "blue";
          options[2] = "green";
          create_survey{value: 1 ether}("Survey 1", "What is your favorite color?", options, 1, 4,1234);

```
---

+ View a survey
```
    viewSurvey(string memory _surveyName) public returns 
    (string memory, string memory, string[] memory,uint256[] memory, uint256, uint256, uint256, uint256)
```

It gets all the information of the survey  

```
        (
            string memory surveyName,
            string memory question,
            string[] memory surveyOptions,
            uint256[] memory answers,
            uint256 numAllowedResponses,
            uint256 startTime,
            uint256 endTime,
            uint256 ethReward
        ) = surveyContract.viewSurvey("Survey 1");
```

## Private Functions

+ End now
```
    endNow(string memory _surveyName) private noReentrancy
```
Ends the survey and send the reward to any participant, require the user to be the owner of the survey
```
endNow("surveyName");
```
---

+ End Auto
```
    endAuto(string memory _surveyName) private noReentrancy
```

Ends the survey and send the reward to any participant, no requirement for user roles. Use when a survey is expired.

```
endAtuo("surveyName");
```

## Components

+ struct Survey, used to store the survey infomation
+ struct registered_user, used to store user information
+ modifier noReentrancy(), a modifier to prevent reentrancy
+ mapping(string => Survey) private user_surveys, it's used to map a survey name to a survey
+ mapping(string => uint256) private balances, keep track of the balance of each survey

## Roles
+ Register user: Can create a survey, can vote for any survey, can end the survey he creates
+ Unregistered user: Can only vote for any survey



