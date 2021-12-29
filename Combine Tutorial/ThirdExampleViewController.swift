//
//  ThirdExampleViewController.swift
//  Combine Tutorial
//
//  Created by Felipe Vidal on 28/12/21.
//

import UIKit
import Combine

class ThirdExampleViewController: UIViewController {

    private let nameIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .secondaryLabel
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Wizard Name"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let passwordIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "lock.circle")
        imageView.tintColor = .secondaryLabel
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Password"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let repeatIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "lock.circle")
        imageView.tintColor = .secondaryLabel
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let repeatTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Repeat Password"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Account", for: .normal)
        button.isEnabled = false
        
        var configuration = UIButton.Configuration.filled()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        button.configuration = configuration
        
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Define our publishers
    @Published private var username = ""
    @Published private var password = ""
    @Published private var passwordAgain = ""
    
    // Define our validation stream
    var validateUsername: AnyPublisher<String?, Never> {
        return $username
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .flatMap { username in
                return Future { promise in
                    self.checkUsernameAvailable(username) { isAvailable in
                        promise(.success(isAvailable ? username : nil))
                    }
                }
            }
            .eraseToAnyPublisher()
    }
    
    var validatePassword: AnyPublisher<String?, Never> {
        return Publishers.CombineLatest($password, $passwordAgain)
            .map { password, passwordRepeat in
                guard password == passwordRepeat, password.count > 0 else { return nil }
                return password
            }
            .map {
                ($0 ?? "") == "password1" ? nil : $0
            }
            .eraseToAnyPublisher()
    }
    
    var validateCredentials: AnyPublisher<(String, String)?, Never> {
        return Publishers.CombineLatest(validateUsername, validatePassword)
            .receive(on: RunLoop.main)
            .map { username, password in
                guard let username = username, let password = password else { return nil }
                return (username, password)
            }
            .eraseToAnyPublisher()
    }
    
    private var createButtonSubscriber: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Wizard School"
        
        view.backgroundColor = .systemBackground
        
        nameTextField.addTarget(self, action: #selector(usernameChanged(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordChanged(_:)), for: .editingChanged)
        repeatTextField.addTarget(self, action: #selector(passwordAgainChanged(_:)), for: .editingChanged)
        createButton.addTarget(self, action: #selector(createButtonTapped(_:)), for: .touchUpInside)
        
        createButtonSubscriber = validateCredentials
            .map { $0 != nil }
            .receive(on: RunLoop.main)
            .assign(to: \.isEnabled, on: createButton)
    }
    
    override func loadView() {
        super.loadView()
        
        let stack1 = UIStackView(arrangedSubviews: [nameIconImageView, nameTextField])
        stack1.alignment = .center
        stack1.spacing = 16
        stack1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack1)
        
        NSLayoutConstraint.activate([
            stack1.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack1.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stack1.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameIconImageView.widthAnchor.constraint(equalToConstant: 35),
            nameIconImageView.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        let stack2 = UIStackView(arrangedSubviews: [passwordIconImageView, passwordTextField])
        stack2.alignment = .center
        stack2.spacing = 16
        stack2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack2)
        
        NSLayoutConstraint.activate([
            stack2.topAnchor.constraint(equalTo: stack1.bottomAnchor, constant: 16),
            stack2.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stack2.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            passwordIconImageView.widthAnchor.constraint(equalToConstant: 35),
            passwordIconImageView.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        let stack3 = UIStackView(arrangedSubviews: [repeatIconImageView, repeatTextField])
        stack3.alignment = .center
        stack3.spacing = 16
        stack3.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack3)
        
        NSLayoutConstraint.activate([
            stack3.topAnchor.constraint(equalTo: stack2.bottomAnchor, constant: 16),
            stack3.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stack3.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            repeatIconImageView.widthAnchor.constraint(equalToConstant: 35),
            repeatIconImageView.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        view.addSubview(createButton)
        
        NSLayoutConstraint.activate([
            createButton.topAnchor.constraint(equalTo: stack3.bottomAnchor, constant: 32),
            createButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            createButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Functions
    
    private func checkUsernameAvailable(_ username: String, completion: (Bool) -> Void) {
        completion(!username.isEmpty ? true : false) // Fake asynchronous backend service
    }
    
    // MARK: - Actions
    
    @objc private func usernameChanged(_ sender: UITextField) {
        username = sender.text ?? ""
    }
    
    @objc private func passwordChanged(_ sender: UITextField) {
        password = sender.text ?? ""
    }
    
    @objc private func passwordAgainChanged(_ sender: UITextField) {
        passwordAgain = sender.text ?? ""
    }
    
    @objc private func createButtonTapped(_ sender: UIButton) {
        
    }

}

#if DEBUG
import SwiftUI

struct ThirdExampleViewControllerPreviews: PreviewProvider {
    
    static var previews: some View {
        ContainerPreview()
            .ignoresSafeArea()
    }
    
    struct ContainerPreview: UIViewControllerRepresentable {
        typealias UIViewControllerType = UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            return ThirdExampleViewController()
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    }
}
#endif
