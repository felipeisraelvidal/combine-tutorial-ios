//
//  FirstExampleViewController.swift
//  Combine Tutorial
//
//  Created by Felipe Vidal on 28/12/21.
//

import UIKit
import Combine

extension Notification.Name {
    static let newBlogPost = Notification.Name("newPost")
}

struct BlogPost {
    let title: String
}

class FirstExampleViewController: UIViewController {

    private let blogTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "New blog post"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let publishButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Publish", for: .normal)
        
        var configuration = UIButton.Configuration.filled()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        button.configuration = configuration
        
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let subscribedLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.text = "Subscriber"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Blog Post"
        
        view.backgroundColor = .systemBackground
        
        publishButton.addTarget(self, action: #selector(publishButtonTapped(_:)), for: .touchUpInside)
        
        // Create a publisher
        let publisher = NotificationCenter.Publisher(center: .default, name: .newBlogPost, object: nil)
            .map { notification -> String? in
                return (notification.object as? BlogPost)?.title ?? ""
            }
        
        // Create a subscriber
        let subscriber = Subscribers.Assign(object: subscribedLabel, keyPath: \.text)
        publisher.subscribe(subscriber)
    }
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(blogTextField)
        NSLayoutConstraint.activate([
            blogTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            blogTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            blogTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(publishButton)
        NSLayoutConstraint.activate([
            publishButton.topAnchor.constraint(equalTo: blogTextField.bottomAnchor, constant: 16),
            publishButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            publishButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(subscribedLabel)
        NSLayoutConstraint.activate([
            subscribedLabel.topAnchor.constraint(equalTo: publishButton.bottomAnchor, constant: 32),
            subscribedLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            subscribedLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            subscribedLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    @objc private func publishButtonTapped(_ sender: UIButton) {
        let title = blogTextField.text ?? "Coming Soon"
        let blogPost = BlogPost(title: title)
        NotificationCenter.default.post(name: .newBlogPost, object: blogPost)
    }
    
}

#if DEBUG
import SwiftUI

struct FirstExampleViewControllerPreviews: PreviewProvider {
    
    static var previews: some View {
        ContainerPreview()
            .ignoresSafeArea()
    }
    
    struct ContainerPreview: UIViewControllerRepresentable {
        typealias UIViewControllerType = UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            return FirstExampleViewController()
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    }
}
#endif
