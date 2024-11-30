import SwiftUI

struct MenuButton: View {
    let title: String
    let icon: String
    var action: (() -> Void)? = nil
    var isNavigationLink: Bool = false
    
    var body: some View {
        Group {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .padding(.bottom, 5)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 150, height: 150)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(AppColors.forestGreen)
                    .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .if(!isNavigationLink) { view in
            Button(action: {
                action?()
            }) {
                view
            }
        }
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            self
        } else {
            transform(self)
        }
    }
}

#Preview {
    MenuButton(title: "Test", icon: "photo.stack")
}
