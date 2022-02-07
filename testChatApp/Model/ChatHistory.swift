//
//  ChatHistory.swift
//  testChatApp
//
//  Created by Julian Silvestri on 2022-02-03.
//

import Foundation

class chatHistory {
    
    //History Dict
    //Key = User
    //Value = Response
    static var chatHistory = [String?:String?]()
    static var localSessionHistory = [chatHistory]
    var userText: String?
    var responseText: String?
    
    init(userText: String?, responeText: String?){
        self.userText = userText
        self.responseText = responeText
    }
    deinit{
        print("remove chats")
    }
}
