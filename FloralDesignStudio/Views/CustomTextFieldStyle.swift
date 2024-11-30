import SwiftUI

struct FloralTextFieldModifier: ViewModifier {
    let floralGreen = Color(red: 34/255, green: 139/255, blue: 34/255)
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.white)
                    .opacity(0.8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(floralGreen, lineWidth: 1)
                    )
            )
            .padding(.horizontal, 40)
    }
}

extension View {
    func floralTextFieldStyle() -> some View {
        modifier(FloralTextFieldModifier())
    }
}
