// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract CrowdFunding {
    enum FundraisingState {
        Opened,
        Closed
    }

    struct Contribution {
        address contribuitor;
        uint value;
    }

    struct Project {
        string id;
        string projectName;
        string description;
        address payable author;
        FundraisingState state;
        uint funds;
        uint fundraisingGoal;
    }

    Project[] public projects;
    mapping(string => Contribution[]) public contribuitons;

    event ProjectCreated(
        string projectId,
        string proectName,
        string description,
        uint fundraisingGoal
    );

    event ProjectFunded(string projectId, uint value);

    event ProjectStateChanged(string id, FundraisingState state);

    modifier isAuthor(uint projectIndex) {
        require(
            msg.sender == projects[projectIndex].author,
            "Only owner can change status"
        );
        _;
    }

    modifier isNotAuthor(uint projectIndex) {
        require(
            msg.sender != projects[projectIndex].author,
            "Owner cant fund own project"
        );
        _;
    }

    function createProject(
        string calldata _id,
        string calldata _projectName,
        string calldata _description,
        uint _fundraisingGoal
    ) public {
        require(
            _fundraisingGoal > 0,
            "Fundraising goal must be greater than 0"
        );
        Project memory project = Project(
            _id,
            _projectName,
            _description,
            payable(msg.sender),
            FundraisingState.Opened,
            0,
            _fundraisingGoal
        );
        projects.push(project);
        emit ProjectCreated(_id, _projectName, _description, _fundraisingGoal);
    }

    function fundProject(
        uint projectIndex
    ) public payable isNotAuthor(projectIndex) {
        Project memory project = projects[projectIndex];
        require(
            project.state != FundraisingState.Closed,
            "Cant found to closed project"
        );
        require(msg.value > 0, "Fund value most be greater than 0");
        project.author.transfer(msg.value);
        project.funds += msg.value;
        projects[projectIndex] = project;

        contribuitons[project.id].push(Contribution(msg.sender, msg.value));

        emit ProjectFunded(project.id, msg.value);
    }

    function changeProjectState(
        uint projectIndex,
        FundraisingState newState
    ) public isAuthor(projectIndex) {
        Project memory project = projects[projectIndex];
        require(project.state != newState, "Cant assign same state");
        project.state = newState;
        projects[projectIndex] = project;
        emit ProjectStateChanged(project.id, newState);
    }

    function compareStrings(
        string memory a,
        string memory b
    ) public pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
