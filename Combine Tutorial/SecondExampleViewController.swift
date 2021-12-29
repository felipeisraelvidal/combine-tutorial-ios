//
//  SecondExampleViewController.swift
//  Combine Tutorial
//
//  Created by Felipe Vidal on 28/12/21.
//

import UIKit
import Combine

class SecondExampleViewController: UIViewController {

    // Define publishers
    @Published private var acceptedTerms = false
    @Published private var acceptedPrivacy = false
    @Published private var name = ""
    
    // Combine publishers into single stream
    private var validToSubmit: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest3($acceptedTerms, $acceptedPrivacy, $name)
            .map({ terms, privacy, name in
                // Logic
                return terms && privacy && !name.isEmpty
            })
            .eraseToAnyPublisher()
    }
    
    private var buttonSubscriber: AnyCancellable?
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter your name"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let acceptedTermsLabel: UILabel = {
        let label = UILabel()
        label.text = "I accept the terms and conditions"
        return label
    }()
    
    private let acceptedTermsSwitch: UISwitch = {
        let swt = UISwitch()
        return swt
    }()
    
    private let acceptedPrivacyLabel: UILabel = {
        let label = UILabel()
        label.text = "I accept the privacy policy"
        return label
    }()
    
    private let acceptedPrivacySwitch: UISwitch = {
        let swt = UISwitch()
        return swt
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        
        var configuration = UIButton.Configuration.filled()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        button.configuration = configuration
        
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Terms & Conditions"
        
        view.backgroundColor = .systemBackground
        
        acceptedTermsSwitch.addTarget(self, action: #selector(acceptTerms(_:)), for: .valueChanged)
        acceptedPrivacySwitch.addTarget(self, action: #selector(acceptPrivacy(_:)), for: .valueChanged)
        nameTextField.addTarget(self, action: #selector(nameChanged(_:)), for: .editingChanged)
        submitButton.addTarget(self, action: #selector(submitAction(_:)), for: .touchUpInside)
        
        // Hook subscriber up to publisher
        buttonSubscriber = validToSubmit
            .receive(on: RunLoop.main)
            .assign(to: \.isEnabled, on: submitButton)
    }
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(nameTextField)
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        let stack1 = UIStackView(arrangedSubviews: [acceptedTermsLabel, acceptedTermsSwitch])
        stack1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack1)
        
        NSLayoutConstraint.activate([
            stack1.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            stack1.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stack1.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        let stack2 = UIStackView(arrangedSubviews: [acceptedPrivacyLabel, acceptedPrivacySwitch])
        stack2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack2)
        
        NSLayoutConstraint.activate([
            stack2.topAnchor.constraint(equalTo: stack1.bottomAnchor, constant: 16),
            stack2.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stack2.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(submitButton)
        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: stack2.bottomAnchor, constant: 16),
            submitButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            submitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Actions
    @objc private func acceptTerms(_ sender: UISwitch) {
        acceptedTerms = sender.isOn
    }
    
    @objc private func acceptPrivacy(_ sender: UISwitch) {
        acceptedPrivacy = sender.isOn
    }
    
    @objc private func nameChanged(_ sender: UITextField) {
        name = sender.text ?? ""
    }
    
    @objc private func submitAction(_ sender: UIButton) {
        
    }

}

#if DEBUG
import SwiftUI

struct SecondExampleViewControllerPreviews: PreviewProvider {
    
    static var previews: some View {
        ContainerPreview()
            .ignoresSafeArea()
    }
    
    struct ContainerPreview: UIViewControllerRepresentable {
        typealias UIViewControllerType = UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            return SecondExampleViewController()
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    }
}
#endif
