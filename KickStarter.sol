pragma solidity ^0.4.17;

contract Master{

    address[] public deployedCompaigns;

    function createChildCompaign(uint _minimum) public{
        address newCompaign = new KsCompaign(_minimum, msg.sender);
        deployedCompaigns.push(newCompaign);
    }

    function getDeployedCompaigns() public view returns (address[]){
        return deployedCompaigns;
    }


}

contract KsCompaign{

    struct Request{
        string description;
        uint value;
        address recipient;
        bool complete;
        uint approvalCount;
        mapping(address=>bool) approvals;        
    }

    address public manager;
    uint public minContribution;
    mapping(address => bool) public approvers;
    Request[] public requests;
    uint approversCount;

    function KsCompaign(uint _minimum, address _deployer) public{
        manager = _deployer;
        minContribution = _minimum;
    }

    modifier onlyManager(){
        require(msg.sender == manager);
        _;
    }

    function contribute() public payable{
        require(msg.value > minContribution);
        approvers[msg.sender] = true;
        approversCount++;
    }

    function createRequest(string _description, uint _value, address _recipient) public onlyManager{        
        Request memory newRequest = Request({
            description: _description,
            value: _value,
            recipient: _recipient,
            complete: false,
            approvalCount:0
        });
        requests.push(newRequest);
    }
    
     function approveRequest(uint _index) public{
        Request storage request = requests[_index];
        require(approvers[msg.sender]);
        require(!request.approvals[msg.sender]);
        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }

    function pushRequest(uint _index) public onlyManager{
        Request storage request = requests[_index];
        require(request.approvalCount > (approversCount/2));
        require(!request.complete);
        request.recipient.transfer(request.value);
        request.complete = true;
    }

}