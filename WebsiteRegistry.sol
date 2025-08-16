// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract WebsiteRegistry {
    struct Website {
        string url;
        address owner;
        uint256 paywall;
    }
    
    mapping(string => Website) public websiteRegistry;
    mapping(address => string[]) private ownerWebsiteUrls;
    string[] private allWebsiteUrls;

    event WebsiteRegistered(address indexed websiteOwner, string websiteUrl, uint256 paywall);
    event WebsiteRemoved(address indexed websiteOwner, string websiteUrl);
    event PaywallUpdated(address indexed websiteOwner, string websiteUrl, uint256 newPaywall);

    function registerWebsite(string memory _websiteUrl, address _websiteOwner, uint256 _paywall) public {
        require(bytes(websiteRegistry[_websiteUrl].url).length == 0, "Website already registered");
        
        Website memory newWebsite = Website(_websiteUrl, _websiteOwner, _paywall);
        websiteRegistry[_websiteUrl] = newWebsite;
        ownerWebsiteUrls[_websiteOwner].push(_websiteUrl);
        allWebsiteUrls.push(_websiteUrl);
        
        emit WebsiteRegistered(_websiteOwner, _websiteUrl, _paywall);
    }

    function removeWebsite(string memory _websiteUrl) public {
        require(bytes(websiteRegistry[_websiteUrl].url).length > 0, "Website not found");
        address websiteOwner = websiteRegistry[_websiteUrl].owner;
        require(websiteOwner == msg.sender, "Only website owner can remove");
        
        delete websiteRegistry[_websiteUrl];
        
        string[] storage ownerUrls = ownerWebsiteUrls[websiteOwner];
        for (uint256 i = 0; i < ownerUrls.length; i++) {
            if (keccak256(abi.encodePacked(ownerUrls[i])) == keccak256(abi.encodePacked(_websiteUrl))) {
                ownerUrls[i] = ownerUrls[ownerUrls.length - 1];
                ownerUrls.pop();
                break;
            }
        }
        
        for (uint256 i = 0; i < allWebsiteUrls.length; i++) {
            if (keccak256(abi.encodePacked(allWebsiteUrls[i])) == keccak256(abi.encodePacked(_websiteUrl))) {
                allWebsiteUrls[i] = allWebsiteUrls[allWebsiteUrls.length - 1];
                allWebsiteUrls.pop();
                break;
            }
        }
        
        emit WebsiteRemoved(websiteOwner, _websiteUrl);
    }

    function updatePaywall(string memory _websiteUrl, uint256 _newPaywall) public {
        require(bytes(websiteRegistry[_websiteUrl].url).length > 0, "Website not found");
        require(websiteRegistry[_websiteUrl].owner == msg.sender, "Only website owner can update paywall");
        
        websiteRegistry[_websiteUrl].paywall = _newPaywall;
        emit PaywallUpdated(msg.sender, _websiteUrl, _newPaywall);
    }

    function getWebsite(string memory _websiteUrl) public view returns (Website memory) {
        require(bytes(websiteRegistry[_websiteUrl].url).length > 0, "Website not found");
        return websiteRegistry[_websiteUrl];
    }

    function getWebsiteOwner(string memory _websiteUrl) public view returns (address) {
        return websiteRegistry[_websiteUrl].owner;
    }

    function getWebsitePaywall(string memory _websiteUrl) public view returns (uint256) {
        return websiteRegistry[_websiteUrl].paywall;
    }

    function getWebsites(address _websiteOwner) public view returns (Website[] memory) {
        string[] memory urls = ownerWebsiteUrls[_websiteOwner];
        Website[] memory websites = new Website[](urls.length);
        
        for (uint256 i = 0; i < urls.length; i++) {
            websites[i] = websiteRegistry[urls[i]];
        }
        
        return websites;
    }

    function getWebsiteUrls(address _websiteOwner) public view returns (string[] memory) {
        return ownerWebsiteUrls[_websiteOwner];
    }

    function getWebsiteCount(address _websiteOwner) public view returns (uint256) {
        return ownerWebsiteUrls[_websiteOwner].length;
    }

    function hasWebsite(address _websiteOwner, string memory _websiteUrl) public view returns (bool) {
        return websiteRegistry[_websiteUrl].owner == _websiteOwner && 
               bytes(websiteRegistry[_websiteUrl].url).length > 0;
    }

    function isWebsiteRegistered(string memory _websiteUrl) public view returns (bool) {
        return bytes(websiteRegistry[_websiteUrl].url).length > 0;
    }

    function getAllWebsites() public view returns (Website[] memory) {
        Website[] memory websites = new Website[](allWebsiteUrls.length);
        
        for (uint256 i = 0; i < allWebsiteUrls.length; i++) {
            websites[i] = websiteRegistry[allWebsiteUrls[i]];
        }
        
        return websites;
    }

    function getAllWebsiteUrls() public view returns (string[] memory) {
        return allWebsiteUrls;
    }

    function getTotalWebsiteCount() public view returns (uint256) {
        return allWebsiteUrls.length;
    }

    function getWebsitesByPaywallRange(uint256 _minPaywall, uint256 _maxPaywall) public view returns (Website[] memory) {
        uint256 count = 0;
        
        for (uint256 i = 0; i < allWebsiteUrls.length; i++) {
            Website memory site = websiteRegistry[allWebsiteUrls[i]];
            if (site.paywall >= _minPaywall && site.paywall <= _maxPaywall) {
                count++;
            }
        }
        
        Website[] memory result = new Website[](count);
        uint256 index = 0;
        
        for (uint256 i = 0; i < allWebsiteUrls.length; i++) {
            Website memory site = websiteRegistry[allWebsiteUrls[i]];
            if (site.paywall >= _minPaywall && site.paywall <= _maxPaywall) {
                result[index] = site;
                index++;
            }
        }
        
        return result;
    }
}