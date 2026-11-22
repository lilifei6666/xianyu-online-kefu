import SwiftUI

struct LoginView: View {
    @EnvironmentObject var state: AppState
    @State private var username = AppSettings.username ?? ""
    @State private var password = ""
    @State private var server = AppSettings.serverURL.absoluteString
    @State private var busy = false
    @State private var showServerField = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 22) {
                    // 品牌区
                    VStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(LinearGradient(colors: [Theme.accent, Color(red: 0.36, green: 0.30, blue: 0.92)],
                                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 84, height: 84)
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        Text("在线客服")
                            .font(.system(size: 26, weight: .bold))
                        Text("登录你的闲鱼客服账号")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)

                    VStack(spacing: 14) {
                        field(icon: "person.fill", placeholder: "用户名", text: $username, secure: false)
                        field(icon: "lock.fill", placeholder: "密码", text: $password, secure: true)

                        if showServerField {
                            field(icon: "network", placeholder: "服务地址，如 http://192.168.1.10:9000",
                                  text: $server, secure: false, keyboard: .URL)
                        } else {
                            Button("修改服务地址") {
                                withAnimation { showServerField = true }
                            }
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 20)

                    if let err = state.errorText {
                        ErrorBanner(text: err)
                    }

                    Button {
                        Task { await submit() }
                    } label: {
                        HStack {
                            if busy { ProgressView().tint(.white) }
                            Text(busy ? "登录中…" : "登 录")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.accent.opacity(canSubmit ? 1 : 0.4))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!canSubmit || busy)
                    .padding(.horizontal, 20)

                    Text("服务端需与手机在同一网络（或已做内网穿透）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }

    private var canSubmit: Bool {
        !username.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty
    }

    @MainActor
    private func submit() async {
        busy = true
        defer { busy = false }
        if server != AppSettings.serverURL.absoluteString {
            await state.setServer(server.trimmingCharacters(in: .whitespaces))
        }
        await state.login(username: username.trimmingCharacters(in: .whitespaces), password: password)
    }

    @ViewBuilder
    private func field(icon: String, placeholder: String, text: Binding<String>,
                       secure: Bool, keyboard: UIKeyboardType = .default) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 18)
            if secure {
                SecureField(placeholder, text: text)
            } else {
                TextField(placeholder, text: text)
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
}
