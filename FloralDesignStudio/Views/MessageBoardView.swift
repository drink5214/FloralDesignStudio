import SwiftUI
import Foundation

struct MessageBubble: View {
    let message: Message
    let currentUser: User?
    
    private var isFromCurrentUser: Bool {
        currentUser?.id == message.sender.id
    }
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading) {
                Text(message.content)
                    .padding(12)
                    .background(isFromCurrentUser ? Color.blue : Color(.systemGray5))
                    .foregroundColor(isFromCurrentUser ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Text(message.displayTimestamp)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            
            if !isFromCurrentUser {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct MessagesListView: View {
    let messages: [Message]
    let currentUser: User?
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(messages) { message in
                        MessageBubble(message: message, currentUser: currentUser)
                            .id(message.id)
                    }
                }
            }
            .onChange(of: messages) { oldValue, newValue in
                withAnimation {
                    proxy.scrollTo(newValue.last?.id, anchor: .bottom)
                }
            }
        }
    }
}

struct MessageBoardView: View {
    @ObservedObject var viewModel: FloralDesignViewModel
    @State private var messageText = ""
    @State private var messages: [Message] = []
    @Environment(\.dismiss) private var dismiss
    
    private let designer = User(
        username: "Designer",
        email: "designer@example.com",
        role: .designer
    )
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages List
            MessagesListView(messages: messages, currentUser: viewModel.currentUser)
            
            // Message Input
            HStack(spacing: 12) {
                TextField("Message", text: $messageText)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.blue)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(.systemGray5)),
                alignment: .top
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Messages")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
        }
        .onAppear {
            loadInitialMessages()
        }
    }
    
    private func loadInitialMessages() {
        guard let currentUser = viewModel.currentUser else { return }
        
        // Load sample messages with timestamps spaced out
        let now = Date()
        messages = [
            Message(
                content: "Hi there! How can I help with your floral design?",
                sender: designer,
                receiver: currentUser,
                createdAt: now.addingTimeInterval(-3600),
                updatedAt: now.addingTimeInterval(-3600)
            ),
            Message(
                content: "I'd like to discuss the color scheme for my wedding bouquet",
                sender: currentUser,
                receiver: designer,
                createdAt: now.addingTimeInterval(-3300),
                updatedAt: now.addingTimeInterval(-3300)
            ),
            Message(
                content: "Of course! What colors are you considering?",
                sender: designer,
                receiver: currentUser,
                createdAt: now.addingTimeInterval(-3000),
                updatedAt: now.addingTimeInterval(-3000)
            )
        ]
    }
    
    private func sendMessage() {
        guard let currentUser = viewModel.currentUser else { return }
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Create and add the user's message
        let newMessage = Message(
            content: messageText,
            sender: currentUser,
            receiver: designer
        )
        messages.append(newMessage)
        messageText = ""
        
        // Simulate designer response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let response = Message(
                content: "Thanks for your message! I'll get back to you soon.",
                sender: designer,
                receiver: currentUser
            )
            messages.append(response)
        }
    }
}

#Preview {
    NavigationView {
        MessageBoardView(viewModel: FloralDesignViewModel())
    }
}
