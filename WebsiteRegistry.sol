// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract WebsiteRegistry {
    mapping(string => address) public websiteRegistry;
    mapping(address => string[]) private ownerWebsites;
    string[] private allWebsites;

    event WebsiteRegistered(address indexed websiteOwner, string websiteUrl);
    event WebsiteRemoved(address indexed websiteOwner, string websiteUrl);

    function registerWebsite(string memory _websiteUrl, address _websiteOwner) public {
        require(websiteRegistry[_websiteUrl] == address(0), "Website already registered");
        
        websiteRegistry[_websiteUrl] = _websiteOwner;
        ownerWebsites[_websiteOwner].push(_websiteUrl);
        allWebsites.push(_websiteUrl);
        
        emit WebsiteRegistered(_websiteOwner, _websiteUrl);
    }

    function removeWebsite(string memory _websiteUrl) public {
        address websiteOwner = websiteRegistry[_websiteUrl];
        require(websiteOwner != address(0), "Website not found");
        require(websiteOwner == msg.sender, "Only website owner can remove");
        
        delete websiteRegistry[_websiteUrl];
        
        string[] storage ownerSites = ownerWebsites[websiteOwner];
        for (uint256 i = 0; i < ownerSites.length; i++) {
            if (keccak256(abi.encodePacked(ownerSites[i])) == keccak256(abi.encodePacked(_websiteUrl))) {
                ownerSites[i] = ownerSites[ownerSites.length - 1];
                ownerSites.pop();
                break;
            }
        }
        
        for (uint256 i = 0; i < allWebsites.length; i++) {
            if (keccak256(abi.encodePacked(allWebsites[i])) == keccak256(abi.encodePacked(_websiteUrl))) {
                allWebsites[i] = allWebsites[allWebsites.length - 1];
                allWebsites.pop();
                break;
            }
        }
        
        emit WebsiteRemoved(websiteOwner, _websiteUrl);
    }

    function getWebsiteOwner(string memory _websiteUrl) public view returns (address) {
        return websiteRegistry[_websiteUrl];
    }

    function getWebsites(address _websiteOwner) public view returns (string[] memory) {
        return ownerWebsites[_websiteOwner];
    }

    function getWebsiteCount(address _websiteOwner) public view returns (uint256) {
        return ownerWebsites[_websiteOwner].length;
    }

    function hasWebsite(address _websiteOwner, string memory _websiteUrl) public view returns (bool) {
        return websiteRegistry[_websiteUrl] == _websiteOwner;
    }

    function isWebsiteRegistered(string memory _websiteUrl) public view returns (bool) {
        return websiteRegistry[_websiteUrl] != address(0);
    }

    function getAllWebsites() public view returns (string[] memory) {
        return allWebsites;
    }

    function getTotalWebsiteCount() public view returns (uint256) {
        return allWebsites.length;
    }
}