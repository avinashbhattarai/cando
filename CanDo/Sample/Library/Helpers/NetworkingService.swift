//
//  NetworkingService.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 25.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import Foundation
import Moya



public enum NetworkingService {
    case CreateUser(firstName: String, lastName: String, email: String, facebookId: String?)
    case VerificateUser(code: Int, email: String)
    case SetPasswordForUser(password: String, code: Int, email: String)
    case ResetPasswordForUser(password: String, code: Int, email: String)
    case LoginUser(password: String?, email: String?, facebookId: String?)
    case ForgotPassword(email: String)
    
    case TeamInfo()
    case CreateTeam()
    case DeleteTeam()
    case LeaveTeam()
    case InviteToTeam(email: String)
    case AcceptInvite(teamId: Int)
    case RemoveFromTeam(memberId: Int)
    
    case TipsInfo()
    
    case AddList(name: String)
    case AddTodo(listId: Int, name: String, assign_to :Int?, date: String?, time: String?)
    case UpdateTodo(todoId: Int, name: String, assign_to :Int?, date: String?, time: String?)
    case ListsInfo()

    
}

let endpointClosure = { (target: NetworkingService) -> Endpoint<NetworkingService> in
    let url = target.baseURL.URLByAppendingPathComponent(target.path).absoluteString
    let endpoint: Endpoint<NetworkingService> = Endpoint<NetworkingService>(URL: url, sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
    
   if let token: String = Helper.UserDefaults.kStandardUserDefaults.objectForKey(Helper.UserDefaults.kUserToken) as? String
   {
     let encodedToken: String = token.toBase64()
    
     return endpoint.endpointByAddingHTTPHeaderFields(["Authorization": "Bearer \(token)"])
   }
    return endpoint
    
}
private func JSONResponseDataFormatter(data: NSData) -> NSData {
    do {
        let dataAsJSON = try NSJSONSerialization.JSONObjectWithData(data, options: [])
        let prettyData =  try NSJSONSerialization.dataWithJSONObject(dataAsJSON, options: .PrettyPrinted)
        return prettyData
    } catch {
        return data //fallback to original data if it cant be serialized
    }
}


let provider = MoyaProvider<NetworkingService>(endpointClosure: endpointClosure, plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])


// MARK: - TargetType Protocol Implementation
extension NetworkingService: TargetType {
    public var baseURL: NSURL { return NSURL(string: "http://api.cando.dev.letzgro.net")! }
    public var path: String {
        switch self {
        
        case .CreateUser(_, _, _, _):
            return "/user/register"
        case .VerificateUser(_, _):
            return "/user/verification"
        case .SetPasswordForUser(_, _,_):
            return "/user/set-password"
        case .ResetPasswordForUser(_, _,_):
            return "/user/reset"
        case .LoginUser(_, _, _):
            return "/user/login"
        case .ForgotPassword(_):
            return "/user/forgot"
        
        case .TeamInfo():
            return "/team"
        case .CreateTeam():
            return "/team"
        case .DeleteTeam():
            return "/team"
        case .LeaveTeam():
            return "/team/leave"
        case .InviteToTeam(_):
            return "/team/member"
        case .AcceptInvite(_):
            return "/team/accept"
        case .RemoveFromTeam(let memberId):
            return "/team/member/\(memberId)"
            
        case .TipsInfo():
            return "/tips"
            
        case .AddList(_):
            return "/lists"
        case .AddTodo(_,_,_,_,_):
            return "/todo"
        case .UpdateTodo(let todoId,_,_,_,_):
            return "/todo/\(todoId)"
        case .ListsInfo():
            return "/lists"
            
        }
    }
    public var method: Moya.Method {
        switch self {
        case .CreateUser:
            return .POST
        case .VerificateUser:
            return .POST
        case .SetPasswordForUser:
            return .POST
        case .ResetPasswordForUser:
            return .POST
        case .LoginUser:
            return .POST
        case .ForgotPassword:
            return .POST
        case .TeamInfo:
            return .GET
        case .CreateTeam:
            return .POST
        case .DeleteTeam:
            return .DELETE
        case .InviteToTeam:
            return .POST
        case .AcceptInvite:
            return .POST
        case .RemoveFromTeam:
            return .DELETE
        case .LeaveTeam:
            return .GET
        case .TipsInfo:
            return .GET
        case .AddList:
            return .POST
        case .AddTodo:
            return .POST
        case .UpdateTodo:
            return .PUT
        case .ListsInfo:
            return .GET
        }
    }
    public var parameters: [String: AnyObject]? {
        switch self {
        case .CreateUser(let firstName, let lastName, let email, let facebookId):
            var params: [String : AnyObject] = [:]
            params["first_name"] = firstName
            params["last_name"] = lastName
            params["email"] = email
            params["facebook_id"] = facebookId
            return params
            
        case .VerificateUser(let code, let email):
            return ["code": code, "email": email]
            
        case .SetPasswordForUser(let password, let code, let email):
            return ["password": password, "code": code, "email": email]
            
        case .ResetPasswordForUser(let password, let code, let email):
            return ["password": password, "code": code, "email": email]
            
        case .LoginUser(let password, let email, let facebookId):
            var params: [String : AnyObject] = [:]
            params["email"] = email
            params["password"] = password
            params["facebook_id"] = facebookId
            return params
            
        case .ForgotPassword(let email):
            return ["email": email]
            
        case .TeamInfo():
            return nil
        case .CreateTeam():
            return nil
        case .DeleteTeam():
            return nil
        case .LeaveTeam():
            return nil
        case .InviteToTeam(let email):
            return ["email": email]
        case .AcceptInvite(let teamId):
            return ["team_id": teamId]
        case .RemoveFromTeam(let memberId):
            return ["id": memberId]
            
        case .TipsInfo():
            return nil
            
        case .AddList(let name):
            return ["name": name]
        case .AddTodo(let listId, let name, let assign_to, let date, let time):
            var params: [String : AnyObject] = [:]
            params["list_id"] = listId
            params["name"] = name
            params["assign_to"] = assign_to
            params["date"] = date
            params["time"] = time
            return params
        case .UpdateTodo(let todoId, let name, let assign_to, let date, let time):
            var params: [String : AnyObject] = [:]
            params["id"] = todoId
            params["name"] = name
            params["assign_to"] = assign_to
            params["date"] = date
            params["time"] = time
            return params

        case .ListsInfo():
            return nil
            
        }
    }
    public var sampleData: NSData {
        switch self {
        case .CreateUser(let firstName, let lastName, let email, let facebookId):
            return "{\"first_name\": \"\(firstName)\", \"last_name\": \"\(lastName)\", \"email\": \"\(email)\", \"facebook_id\": \"\(facebookId)\"}".UTF8EncodedData
            
        case .VerificateUser(let code, let email):
            return "{\"code\": \"\(code)\", \"email\": \"\(email)\"}".UTF8EncodedData
            
        case .SetPasswordForUser(let code, let email, let password ):
            return "{\"code\": \"\(code)\", \"email\": \"\(email)\", \"password\":\"\(password)\"}".UTF8EncodedData
            
        case .ResetPasswordForUser(let code, let email, let password ):
            return "{\"code\": \"\(code)\", \"email\": \"\(email)\", \"password\":\"\(password)\"}".UTF8EncodedData
            
        case .LoginUser(let password, let email, let facebookId):
            return "{\"password\": \"\(password)\", \"email\": \"\(email)\", \"facebook_id\": \"\(facebookId)\"}".UTF8EncodedData
        case .ForgotPassword(let email):
             return "{\"email\": \"\(email)\"}".UTF8EncodedData
            
        case .TeamInfo():
            return "Half measures are as bad as nothing at all.".UTF8EncodedData
        case .CreateTeam():
            return "Half measures are as bad as nothing at all.".UTF8EncodedData
        case .DeleteTeam():
            return "Half measures are as bad as nothing at all.".UTF8EncodedData
        case .LeaveTeam():
            return "Half measures are as bad as nothing at all.".UTF8EncodedData
        case .InviteToTeam(let email):
            return "{\"email\": \"\(email)\"}".UTF8EncodedData
        case .AcceptInvite(let teamId):
            return "{\"team_id\": \"\(teamId)\"}".UTF8EncodedData
        case .RemoveFromTeam(let memberId):
            return "{\"id\": \"\(memberId)\"}".UTF8EncodedData

        case .TipsInfo():
            return "Half measures are as bad as nothing at all.".UTF8EncodedData
            
        case .AddList(let name):
            return "{\"name\": \"\(name)\"}".UTF8EncodedData
        case .AddTodo(let listId, let name, let assign_to, let date, let time):
            return "{\"list_id\": \"\(listId)\", \"name\": \"\(name)\", \"assign_to\": \"\(assign_to)\", \"date\": \"\(date)\", \"time\": \"\(time)\"}".UTF8EncodedData
        case .UpdateTodo(let todoId, let name, let assign_to, let date, let time):
            return "{\"id\": \"\(todoId)\", \"name\": \"\(name)\", \"assign_to\": \"\(assign_to)\", \"date\": \"\(date)\", \"time\": \"\(time)\"}".UTF8EncodedData
        case .ListsInfo():
            return "Half measures are as bad as nothing at all.".UTF8EncodedData

        }
    }
    public var multipartBody: [MultipartFormData]? {
        // Optional
        return nil
    }
}

// MARK: - Helpers
private extension String {
    var URLEscapedString: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
    }
    var UTF8EncodedData: NSData {
        return self.dataUsingEncoding(NSUTF8StringEncoding)!
    }
}