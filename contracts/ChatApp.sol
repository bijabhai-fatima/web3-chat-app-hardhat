 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract ChatApp {

    struct user {
        string name;
        friend[] friendList;
    }

    struct AllUserStruct {
        string name;
        address accountAddress;
    }

    struct friend {
        address pubkey;
        string name;
    }

    struct message {
        address sender;
        uint256 timestamp;
        string msg;
    }

    AllUserStruct[] getAllUsers;

    mapping(address => user) userList;
    mapping(bytes32 => message[]) allMessages;

    function checkUserExists(address pubkey) public view returns (bool){
        return bytes(userList[pubkey].name).length > 0;
    }

    function createAccount(string calldata name) external {
        require(checkUserExists(msg.sender) == false, "User already exists");
        require(bytes(name).length > 0, "Username cannot be empty");

        userList[msg.sender].name = name;
        getAllUsers.push(AllUserStruct(name, msg.sender));
    }

    function getUsername(address pubkey) external view returns(string memory){
        require(checkUserExists(pubkey), "Username is not registered");
        return userList[pubkey].name;
    }

    function addFriend(address friend_key, string calldata name) external {
        require(checkUserExists(msg.sender), "Create Account first");
        require(checkUserExists(friend_key), "User is not registered");
        require(friend_key != msg.sender, "User cannot add themself as a friend");
        require(checkAlreadyFriends(msg.sender, friend_key) == false, "These users are already friends");

        _addFriend(msg.sender, friend_key, name);
        _addFriend(friend_key, msg.sender, userList[msg.sender].name);
    }

    function checkAlreadyFriends(address pubkey1, address pubkey2) internal view returns(bool) {
        
        if(userList[pubkey1].friendList.length > userList[pubkey2].friendList.length){
            address temp = pubkey1;
            pubkey1 = pubkey2;
            pubkey2 = temp;
        }

        for(uint256 i = 0; i <userList[pubkey1].friendList.length; i++){

            if(userList[pubkey1].friendList[i].pubkey == pubkey2){
                return true;
            }
        }

        return false;
    }

    function _addFriend(address me, address friend_key, string memory name) internal {
        friend memory newFriend = friend(friend_key, name);
        userList[me].friendList.push(newFriend);
    }

    function getMyFriendList() external view returns(friend[] memory){
        return userList[msg.sender].friendList;
    }

    function _getChatCode(address pubkey1, address pubkey2) internal pure returns(bytes32){
        if(pubkey1 < pubkey2){
            return keccak256(abi.encodePacked(pubkey1, pubkey2));
        } 
        else {
            return keccak256(abi.encodePacked(pubkey2, pubkey1));
        }
    }

    function sendMessage(address friend_key, string calldata _msg) external {
        require(checkUserExists(msg.sender), "Create Account first");
        require(checkUserExists(friend_key), "User is not registered");
        require(checkAlreadyFriends(msg.sender, friend_key), "You are not the friend with the given user");

        bytes32 chatCode = _getChatCode(msg.sender, friend_key);
        message memory newMsg = message(msg.sender, block.timestamp, _msg);
        allMessages[chatCode].push(newMsg);
    }

    function readMessage(address friend_key) external view returns(message[] memory){
        bytes32 chatCode = _getChatCode(msg.sender, friend_key);
        return allMessages[chatCode];
    }

    function getAllAppUser() public view returns(AllUserStruct[] memory){
        return getAllUsers;
    }
}