//
//  AuthToken.swift
//  CalCalc
//
//  Created by Ivan Dilchovski on 11/29/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import Foundation
import KeychainAccess
import Result

private struct KeychainKeys {
    static let Service = "LogJog"

    static let Password = "LogJogPassword"
    static let Username = "LogJogUsername"
    static let AccessToken = "LogJogAccessToken"
}

/// Note: loadCurrentUserOnLoginSuccess really should be called on successfull login, as it notifies all relevant

class AccountManager {
    enum LoginError: Error {
        case locallyMissingCredentials
        case expiredCredentials
        case requestError(RequestError)

        var errorMessage: String {
            switch self {
            case .locallyMissingCredentials: return "Local credentials not found"
            case .expiredCredentials: return "Local credentials expired"
            case .requestError(let error): return error.errorMessage
            }
        }

        var isFailedAuthentication: Bool {
            switch self {
            case .locallyMissingCredentials: return true
            case .expiredCredentials: return true
            case .requestError(let error): return error.isFailedAuthentication
            }
        }
    }

    //**********
    // MARK: - Properties
    //**********

    let authRequests: AuthRequests
    let usersRequests: UsersRequests
    let keychain: Keychain
    let notificationCenter: NotificationCenter

    var refreshTokenObserver: NSObjectProtocol? = nil

    private var isLoginInProgress = false


    //**********
    // MARK: - Lifecycle
    //**********

    init(authRequests: AuthRequests = DefaultAuthRequests(),
         usersRequests: UsersRequests = DefaultUsersRequests(),
         keychain: Keychain = Keychain(service: KeychainKeys.Service),
         notificationCenter: NotificationCenter = NotificationCenter.default)
    {
        self.authRequests = authRequests
        self.usersRequests = usersRequests
        self.keychain = keychain
        self.notificationCenter = notificationCenter

        refreshTokenObserver = notificationCenter.addObserver(forType: Notifications.AccountManager.AutoLoginRequest.self, observingObject: nil, queue: nil) { [weak self] notification in
            guard let wself = self else { return }
            log.info("Autologin due to notification")

            if notification.tokenExpired {
                wself.keychain[KeychainKeys.AccessToken] = nil
            }

            wself.tryAutoLogin() { result in
                switch result {
                case .success:
                    log.info("Autologin in response to notification success")

                case .failure(let error):
                    if error.isFailedAuthentication {
                        log.error("Autologin authentication failed")
                    } else {
                        log.error("Autologin error: \(error)")
                    }
                    wself.notifyNewAccessToken(nil)
                }
            }
        }
    }

    deinit {
        if let refreshTokenObserver = refreshTokenObserver {
            notificationCenter.removeObserver(refreshTokenObserver)
        }
    }



    //**********
    // MARK: - Auto-login
    //**********

    // All AutoLogin methods on success will eventually call loadCurrentUserOnLoginSuccess and post UserChanged notification

    /// Attempts to login with a stored access token or username from keychain
    /// On success UserChanged notification is sent
    ///
    /// On .isFailedAuthentication request error tries the next method until all are tried, then calls onFailure, on all other errors immediately calls onFailure and stops further attempts
    func tryAutoLogin(handler: ((Result<User, LoginError>) -> ())?) {
        tryAutoLoginWithSavedAccessToken() { result in
            switch result {
            case .success:
                handler?(result)

            case .failure(let error):
                if case .expiredCredentials = error {
                    handler?(result)
                } else if error.isFailedAuthentication {
                    self.tryAutoLoginFromKeychain() { keychainAutoLoginResult in
                        handler?(keychainAutoLoginResult)
                    }
                } else {
                    log.error("Failed with: \(error.errorMessage)")
                    handler?(result)
                }
            }
        }
    }

    /// Attempts to login with stored token credentials - Previous access tokenor refresh token if the access token has expired
    /// Upon success UserChanged notification is sent
    ///
    /// On any error immediately calls onFailure and stops further attempts
    ///
    /// - parameter onSuccess:     Returns the logged in user with the basic properties fetched
    /// - parameter onFailure:     Any error that has occured
    func tryAutoLoginWithSavedAccessToken(handler: ((Result<User, LoginError>) -> ())?) {
        if let accessToken = keychain[KeychainKeys.AccessToken] {

            // TODO: Decode JWT token and see if already expired

            log.info("Trying to login with stored access token")
            self.notifyNewAccessToken(accessToken)
            self.loadCurrentUserOnLoginSuccess() { result in
                handler?(result.mapError({ error in
                    if case .serverError(let errors) = error, errors.first(where: { $0.identifier == .tokenInvalid }) != nil {
                        self.keychain[KeychainKeys.AccessToken] = nil

                        self.notifyNewAccessToken(nil)
                        return .locallyMissingCredentials
                    } else {
                        return .requestError(error)
                    }
                }))
            }
        } else { // No previous accessToken in keychain
            log.info("No access token")
            handler?(.failure(.locallyMissingCredentials))
        }
    }

    /// Attempts to login with keychain stored credentials - Facebook token, if that fails - username & password
    /// Upon success UserChanged notification is sent
    ///
    /// - parameter onSuccess:     Returns the logged in user with the basic properties fetched
    /// - parameter onFailure:     Any error that has occured
    func tryAutoLoginFromKeychain(handler: ((Result<User, LoginError>) -> ())?) {
        if let username = keychain[KeychainKeys.Username], let password = keychain[KeychainKeys.Password] {
            log.info("Found saved username and pass")
            login(username: username,
                  password: password,
                  handler: { result in
                    handler?(result.mapError({ error in
                        return .requestError(error)
                    }))
            })
        } else {
            log.info("No saved username in Keychain")
            handler?(.failure(.locallyMissingCredentials))
        }
    }


    //**********
    // MARK: - Login
    //**********

    private enum LoginMethod {
        case usernamePass(username: String, password: String)
    }

    /// Attempts to login with the given username and password.
    /// Upon success UserChanged notification is sent
    ///
    /// - parameter username:      Valid app username (email)
    /// - parameter password:      Valid password for the username (email)
    /// - parameter onSuccess:     Returns the logged in user with the basic properties fetched
    /// - parameter onFailure:     Any error that has occured
    func login(username: String,
               password: String,
               handler: ((Result<User, RequestError>) -> ())?) {

        login(with: .usernamePass(username: username, password: password),
              handler: handler)
    }

    func register(withPassword password: String,
                  user: User,
                  handler: ((Result<User, RequestError>) -> ())?) {

        self.usersRequests.register(user: user, withPassword: password, handler: handler)
    }


    func logout() {
        notifyNewAccessToken(nil)
        removeUserAndPassFromKeychain()

        let logoutNotification = Notifications.AccountManager.UserChanged(user: nil, loggedOut: true, observedObject: nil)
        notificationCenter.postTypedNotification(logoutNotification)
    }


    //**********
    // MARK: - Private
    //**********

    /// Tryies to login with the provided login method.
    /// Upon success attempts to fetch the basic (public) user profile
    ///
    /// - parameter loginMethod: LoginMethod - Facebook, User & Pass or Refresh Token
    /// - parameter onSuccess:     Returns the logged in user with the basic properties fetched
    /// - parameter onFailure:     Any error that has occured
    private func login(with loginMethod: LoginMethod,
                           handler: ((Result<User, RequestError>) -> ())?) {

        guard isLoginInProgress == false else {
            log.error("Already logging in")
            handler?(.failure(.requestFailure(message: "Login already in progress")))
            return
        }


        // Different possible login methods, but same success/failure handlers for all of them

        let successClosure: (AuthToken) -> () = { token in
            self.keychain[KeychainKeys.AccessToken] = token.accessToken

            self.notifyNewAccessToken(token.accessToken)

            self.loadCurrentUserOnLoginSuccess() { result in
                self.isLoginInProgress = false
                handler?(result)
            }
        }


        let failureClosure: (RequestError) -> () = { error in

            if error.isFailedAuthentication {
                switch loginMethod
                {
                case .usernamePass:
                    self.keychain[KeychainKeys.Username] = nil
                    self.keychain[KeychainKeys.Password] = nil
                }
            }

            self.isLoginInProgress = false
            handler?(.failure(error))
        }


        isLoginInProgress = true

        switch loginMethod
        {
        case .usernamePass(let username, let password):
            authRequests.login(
                email: username,
                password: password) { result in
                    switch result {
                    case .success(let token):
                        self.keychain[KeychainKeys.Username] = username
                        self.keychain[KeychainKeys.Password] = password
                        successClosure(AuthToken(accessToken: token))

                    case .failure(let error):
                        failureClosure(error)
                    }
            }
        }
    }
    
    // This is THE method to call after successfull login
    private func loadCurrentUserOnLoginSuccess(handler: ((Result<User, RequestError>) -> ())?) {
        usersRequests.getCurrent() { result in
            handler?(result.mapError({ error in
                self.notifyNewAccessToken(nil) // Something went wrong. Soft logout without deleting stored credentials
                return error
            }))
        }
    }
    
    
    private func removeUserAndPassFromKeychain () {
        keychain[KeychainKeys.AccessToken] = nil

        keychain[KeychainKeys.Username] = nil
        keychain[KeychainKeys.Password] = nil
    }
    
    private func notifyNewAccessToken(_ accessToken: String?) {
        log.info("Token updated")
        let tokenNotification = Notifications.Networking.AuthTokenUpdated(accessToken: accessToken)
        notificationCenter.postTypedNotification(tokenNotification)
    }
}
