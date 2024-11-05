//
//  PasswordField.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 05.11.2023.
//

import SwiftUI

struct PasswordField: View {
    let label: LocalizedStringKey
    @Binding var text: String

    @State private var showText: Bool = false
    @FocusState private var focus: Focus?
    @Environment(\.scenePhase) private var scenePhase
    
    init(_ label: LocalizedStringKey, text: Binding<String>) {
        self.label = label
        self._text = text
    }

    var body: some View {
        ZStack {
            SecureField(label, text: $text)
                .focused($focus, equals: .secure)
                .opacity(showText ? 0 : 1)
            TextField(label, text: $text)
                .focused($focus, equals: .text)
                .opacity(showText ? 1 : 0)
        }
        .overlay(alignment: .trailing) {
            Button {
                showText.toggle()
            } label: {
                Image(systemName: showText ? "eye.slash.fill" : "eye.fill")
                    .frame(width: 50, height: 50)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accentColor(.secondary)
        }
        .onChange(of: focus) { old, new in
            if new != nil {
                focus = showText ? .text : .secure
            }
        }
        .onChange(of: scenePhase) { old, new in
            if new != .active {
                showText = false
            }
        }
        .onChange(of: showText) { old, new in
            if focus != nil {
                focus = new ? .text : .secure
            }
        }
    }
}

extension PasswordField {
    private enum Focus {
        case secure, text
    }
}

struct PasswordField_Previews: PreviewProvider {
    static var previews: some View {
        PasswordField("Password", text: .constant("Lorem Ipsum"))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
