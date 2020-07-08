//
//  RegisterViewController.swift
//  NotesApp
//
//  Created by Danny Vo on 2020-07-07.
//  Copyright © 2020 Danny Vo. All rights reserved.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let firstnameField: UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.placeholder = "First Name"
        return field
    }()
    
    private let lastnameField: UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.placeholder = "Last Name"
        return field
    }()
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.placeholder = "Email Address"
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.placeholder = "Password"
        field.isSecureTextEntry = true
        return field
    }()
    
    private let registerBtn: UIButton = {
        let button = UIButton()
        button.setTitle("Create", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Log In"
        view.backgroundColor = .white
        
        registerBtn.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        emailField.delegate = self
        passwordField.delegate = self
        firstnameField.delegate = self
        lastnameField.delegate = self
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(firstnameField)
        scrollView.addSubview(lastnameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerBtn)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        firstnameField.frame = CGRect(x: 30,
                                      y: 150,
                                      width: scrollView.width-60,
                                      height: 52)
        lastnameField.frame = CGRect(x: 30,
                                     y: firstnameField.bottom+10,
                                     width: scrollView.width-60,
                                     height: 52)
        emailField.frame = CGRect(x: 30,
                                  y: lastnameField.bottom + 10,
                                  width: scrollView.width-60,
                                  height: 52)
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom+10,
                                     width: scrollView.width-60,
                                     height: 52)
        registerBtn.frame = CGRect(x: 30,
                                   y: passwordField.bottom+10,
                                   width: scrollView.width-60,
                                   height: 52)
    }
    
    @objc func registerButtonTapped() {
        firstnameField.resignFirstResponder()
        lastnameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let firstName = firstnameField.text,
            let lastName = lastnameField.text,
            let email = emailField.text,
            let password = passwordField.text,
            !email.isEmpty,
            !password.isEmpty,
            !firstName.isEmpty,
            !lastName.isEmpty,
            password.count >= 6 else {
                alertUserLoginError()
                return
        }
        
        spinner.show(in: view)
        
        // Firebase Registration
        print("Calling log in")
        DatabaseManager.shared.userExists(with: email) { [weak self] exists in
            guard let strongself = self else { return }
            
            DispatchQueue.main.async {
                strongself.spinner.dismiss()
            }
            
            guard !exists else {
                // User Already Exists
                strongself.alertUserLoginError(message: "Looks like a user account for that email address already exists.")
                return
            }
            print("firebase Auth")
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                guard authResult != nil, error == nil else {
                    print("Error creating user")
                    return
                }
                
                let noteUser = NoteUser(firstName: firstName, lastName: lastName, emailAddress: email)
                DatabaseManager.shared.insertUser(with: noteUser) { (success) in
                    if success {
                        print("Inserted successfully")
                    }
                }
            }
            strongself.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func alertUserLoginError(message: String = "Please enter all information to create a new account.") {
        let ac = UIAlertController(title: "Missing information", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstnameField {
            lastnameField.becomeFirstResponder()
        } else if textField == lastnameField {
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            registerButtonTapped()
        }
        return true
    }
}

