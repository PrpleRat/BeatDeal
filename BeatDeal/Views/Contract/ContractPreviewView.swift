import SwiftUI
import WebKit

struct ContractPreviewView: View {
    let contract: Contract
    let pdfURL: URL?
    var onEdit: () -> Void
    var onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var profileStorage = ProfileStorage.shared

    @State private var workingContract: Contract
    @State private var selectedTab = 0
    @State private var showShare = false
    @State private var alertMessage: String?

    init(contract: Contract, pdfURL: URL?, onEdit: @escaping () -> Void, onSaved: @escaping () -> Void) {
        self.contract = contract
        self.pdfURL = pdfURL
        self.onEdit = onEdit
        self.onSaved = onSaved
        _workingContract = State(initialValue: contract)
    }

    private var dmMessage: String {
        DMKitGenerator.generate(contract: workingContract, profile: profileStorage.profile)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Section", selection: $selectedTab) {
                    Text("Contrat").tag(0)
                    Text("DM Kit").tag(1)
                    Text("Livraison").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(BeatDealSpacing.md)

                Group {
                    switch selectedTab {
                    case 0: contractTab
                    case 1: dmTab
                    default: deliveryTab
                    }
                }
                .frame(maxHeight: .infinity)

                actionBar
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

    private var contractTab: some View {
        ContractHTMLPreview(contract: workingContract)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, BeatDealSpacing.md)
    }

    private var dmTab: some View {
        ScrollView {
            DMKitView(message: dmMessage)
                .padding(BeatDealSpacing.md)
        }
    }

    private var deliveryTab: some View {
        ScrollView {
            DeliveryChecklistView(checklist: Binding(
                get: { workingContract.deliveryChecklist ?? DeliveryChecklist() },
                set: { workingContract.deliveryChecklist = $0 }
            ))
            .padding(BeatDealSpacing.md)
        }
    }

    private var actionBar: some View {
        HStack(spacing: BeatDealSpacing.sm) {
            Button("Partager PDF") { showShare = true }
                .buttonStyle(PrimaryButtonStyle())

            Button("Enregistrer") { saveContract() }
                .buttonStyle(SecondaryButtonStyle())

            Button("Modifier") {
                onEdit()
                dismiss()
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding(BeatDealSpacing.md)
    }

    private func saveContract() {
        var saved = workingContract
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
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(ContractHTMLBuilder.buildHTML(for: contract), baseURL: nil)
    }
}
