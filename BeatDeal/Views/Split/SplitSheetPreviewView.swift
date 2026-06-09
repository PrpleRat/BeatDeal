import SwiftUI
import WebKit

struct SplitSheetPreviewView: View {
    let split: SplitSheet
    let pdfURL: URL?
    let onDismiss: () -> Void
    var onEdit: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var showShare = false
    @State private var showContract = false
    @State private var splitImport: SplitPadImport?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SplitHTMLWebView(html: SplitSheetHTMLBuilder.buildHTML(for: split))
                    .frame(maxHeight: .infinity)

                VStack(spacing: BeatDealSpacing.sm) {
                    Button("Partager le PDF") { showShare = true }
                        .buttonStyle(PrimaryButtonStyle())

                    if onEdit != nil {
                        Button("Modifier le split") {
                            dismiss()
                            onEdit?()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }

                    Button("Créer un contrat de licence") {
                        splitImport = SplitPadImport(
                            ref: split.ref,
                            title: split.title,
                            artist: split.artist,
                            coProducerName: split.collaborators.count > 1 ? split.collaborators[1].name : nil,
                            coProducerSharePercent: split.collaborators.count > 1 ? split.collaborators[1].masterShare : nil
                        )
                        showContract = true
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    if let artist = split.artist, !artist.isEmpty {
                        Button("Facturer avec BeatBill") {
                            let email = split.collaborators.first(where: { $0.name == artist })?.email ?? ""
                            BeatBillLink.openInvoice(
                                clientName: artist,
                                clientEmail: email,
                                project: split.title,
                                note: "Split \(split.ref)"
                            )
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                }
                .padding(BeatDealSpacing.md)
                .background(BeatDealColors.card)
            }
            .background(BeatDealColors.background.ignoresSafeArea())
            .navigationTitle("Aperçu split")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") {
                        dismiss()
                        onDismiss()
                    }
                }
            }
            .sheet(isPresented: $showShare) {
                if let pdfURL {
                    ShareSheet(items: [pdfURL])
                }
            }
            .sheet(isPresented: $showContract) {
                if let splitImport {
                    NewContractView(splitImport: splitImport)
                }
            }
        }
    }
}

private struct SplitHTMLWebView: UIViewRepresentable {
    let html: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.loadHTMLString(html, baseURL: nil)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
