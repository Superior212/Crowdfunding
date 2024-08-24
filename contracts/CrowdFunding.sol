// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract CrowdFunding {

     // campaign Struct
    struct Campaign {
        string title;
        string description;
        address payable benefactor;
        uint goal;
        uint deadline;
        uint amountRaised;
        bool ended;
    }

 mapping(uint => Campaign) public campaigns;
    uint public campaignCount;


        // Events
     event CampaignCreated(uint campaignId, string title, uint goal, uint deadline);
     event DonationReceived(uint campaignId, address donor, uint amount);
    event CampaignEnded(uint campaignId, uint amountRaised, bool goalMet);


        // Modifier to check if the campaign deadline has passed
    modifier campaignNotEnded(uint campaignId) {
        require(block.timestamp < campaigns[campaignId].deadline, "Campaign has ended");
        _;
    }

     // Modifier to check if the caller is the owner of the contract
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

     address public owner;

    // Constructor sets the contract owner
    constructor() {
        owner = msg.sender;
    }

        // Function to create a new campaign
    function createCampaign(string memory _title, string memory _description, address payable _benefactor, uint _goal, uint _duration) public {
        require(_goal > 0, "Goal should be greater than zero");

        campaignCount++;
        uint deadline = block.timestamp + _duration;



        campaigns[campaignCount] = Campaign({
            title: _title,
            description: _description,
            benefactor: _benefactor,
            goal: _goal,
            deadline: deadline,
            amountRaised: 0,
            ended: false
        });

        emit CampaignCreated(campaignCount, _title, _goal, deadline);

    }

    // Function to donate to a campaign
    function donateToCampaign(uint _campaignId) public payable campaignNotEnded(_campaignId) {
        Campaign storage campaign = campaigns[_campaignId];
        require(msg.value > 0, "Donation amount should be greater than zero");

        campaign.amountRaised += msg.value;

        emit DonationReceived(_campaignId, msg.sender, msg.value);
    }


    // Function to end a campaign and transfer funds to the benefactor
    function endCampaign(uint _campaignId) public {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp >= campaign.deadline, "Campaign deadline has not yet passed");
        require(!campaign.ended, "Campaign has already ended");

        campaign.ended = true;

        // Transfer the raised funds to the benefactor
        campaign.benefactor.transfer(campaign.amountRaised);

        emit CampaignEnded(_campaignId, campaign.amountRaised, campaign.amountRaised >= campaign.goal);
    }

     // Function to withdraw leftover funds (only owner can do this)
    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}