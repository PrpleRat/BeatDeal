import SwiftUI
import WebKit

struct ContractPreviewView: View {
    let contract: Contract
    let pdfURL: URL?
    var onEdit: () -> Void
    var onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showShare = false
    @State private var alertMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ContractHTMLPreview(contract: contract)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(BeatDealSpacing.md)

                HStack(spacing: BeatDealSpacing.sm) {
                    Button("Partager") {
                        showShare = true
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button("Enregistrer") {
                        saveContract()
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Button("Modifier") {
                        onEdit()
                        dismiss()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .padding(BeatDealSpacing.md)
            }
            .background(BeatDealColors.background.ignoresSafeArea())
            .navigationTitle("Aperçu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
            .sheet(isPresented: $showShare) {
                if let pdfURL {
                    ShareSheet(items: [pdfURL])
                }
            }
            .alert("BeatDeal", isPresented: Binding(
                get: { alertMessage != nil },
                set: { if !$0 { alertMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage ?? "")
            }
        }
    }

    private func saveContract() {
        var saved = contract
        saved.pdfFileName = pdfURL?.lastPathComponent
        ContractStorage.shared.save(saved)
        onSaved()
        dismiss()
    }
}

struct ContractHTMLPreview: UIViewRepresentable {
    let contract: Contract

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .white
        webView.scrollView.backgroundColor = .white
        webView.isUserInteractionEnabled = true
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let html = ContractHTMLBuilder.buildHTML(for: contract)
        webView.loadHTMLString(html, baseURL: nil)
    }
}
