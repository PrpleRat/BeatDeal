import Foundation
import UIKit

enum BeatBillLink {

    /// Ouvre BeatBill avec une facture pré-remplie (`beatbill://invoice?...`).
    static func openInvoice(
        clientName: String,
        clientEmail: String = "",
        project: String,
        amount: Int? = nil,
        note: String? = nil
    ) {
        var components = URLComponents()
        components.scheme = "beatbill"
        components.host = "invoice"
        var items: [URLQueryItem] = [
            URLQueryItem(name: "client", value: clientName),
            URLQueryItem(name: "project", value: project),
        ]
        if !clientEmail.isEmpty {
            items.append(URLQueryItem(name: "email", value: clientEmail))
        }
        if let amount {
            items.append(URLQueryItem(name: "amount", value: String(amount)))
        }
        if let note, !note.isEmpty {
            items.append(URLQueryItem(name: "note", value: note))
        }
        components.queryItems = items

        guard let url = components.url else { return }
        UIApplication.shared.open(url)
    }
}
