import Foundation
import UIKit

enum PDFGenerator {

    static func generatePDF(for contract: Contract) throws -> URL {
        let html = ContractHTMLBuilder.buildHTML(for: contract)
        let formatter = UIMarkupTextPrintFormatter(markupText: html)
        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(formatter, startingAtPageAt: 0)

        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
        let printableRect = pageRect.insetBy(dx: 40, dy: 48)
        renderer.setValue(NSValue(cgRect: pageRect), forKey: "paperRect")
        renderer.setValue(NSValue(cgRect: printableRect), forKey: "printableRect")

        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pageRect, nil)
        for pageIndex in 0..<renderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            renderer.drawPage(at: pageIndex, in: UIGraphicsGetPDFContextBounds())
        }
        UIGraphicsEndPDFContext()

        let fileName = "BeatDeal-\(contract.reference).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try (pdfData as Data).write(to: url, options: .atomic)
        return url
    }
}

enum ContractHTMLBuilder {

    static func buildHTML(for contract: Contract) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "fr_FR")
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        let dateStr = dateFormatter.string(from: contract.createdAt)

        let rightsHTML = ContractRights.allLabels.map { item in
            let granted = contract.rights[keyPath: item.keyPath]
            let mark = granted ? "✓" : "✗"
            let style = granted ? "granted" : "denied"
            return "<li class=\"\(style)\">\(mark) \(escape(item.label))</li>"
        }.joined()

        let streamsLabel: String
        if contract.licenseType.isExclusive {
            streamsLabel = "Illimités"
        } else {
            streamsLabel = "\(contract.maxStreams.formatted()) streams maximum"
        }

        let bpmLine: String
        if let bpm = contract.bpm {
            bpmLine = "BPM : \(bpm)"
        } else {
            bpmLine = "BPM : —"
        }

        let keyLine: String
        if let tonalite = contract.tonaliteLabel {
            keyLine = "Tonalité : \(escape(tonalite))"
        } else {
            keyLine = "Tonalité : —"
        }

        let paymentRef = contract.paymentReference.isEmpty ? "—" : escape(contract.paymentReference)
        let clauses = contract.additionalClauses.isEmpty ? "Aucune" : escape(contract.additionalClauses)

        return """
        <!DOCTYPE html>
        <html lang="fr">
        <head>
          <meta charset="utf-8">
          <style>
            body {
              font-family: Georgia, 'Times New Roman', serif;
              color: #111;
              font-size: 11pt;
              line-height: 1.5;
            }
            h1 {
              text-align: center;
              font-size: 16pt;
              letter-spacing: 0.04em;
              margin-bottom: 8px;
            }
            hr {
              border: none;
              border-top: 1px solid #ccc;
              margin: 16px 0;
            }
            h2 {
              font-size: 11pt;
              text-transform: uppercase;
              letter-spacing: 0.06em;
              margin: 0 0 8px;
            }
            p, li { margin: 4px 0; }
            ul { padding-left: 18px; }
            .granted { color: #111; }
            .denied { color: #888; }
            .footer {
              margin-top: 24px;
              font-size: 9pt;
              color: #666;
              text-align: center;
            }
            .signatures {
              margin-top: 24px;
            }
            .sign-line {
              margin: 18px 0;
            }
          </style>
        </head>
        <body>
          <h1>CONTRAT DE LICENCE DE BEAT</h1>
          <hr>

          <h2>Parties</h2>
          <p><strong>Producteur (Concédant) :</strong><br>
          Nom : \(escape(contract.producerName))<br>
          Alias : \(escape(contract.producerAlias))<br>
          Email : \(escape(contract.producerEmail))<br>
          Pays : \(escape(contract.producerCountry))</p>

          <p><strong>Artiste (Licencié) :</strong><br>
          Nom : \(escape(contract.artistName))<br>
          Email : \(escape(contract.artistEmail))</p>

          <hr>

          <h2>Objet du contrat</h2>
          <p>
            Beat licencié : "\(escape(contract.beatTitle))"<br>
            \(escape(bpmLine)) | \(keyLine)<br>
            Type de licence : \(escape(contract.licenseType.title))<br>
            Date du contrat : \(escape(dateStr))<br>
            Référence : \(escape(contract.reference))
          </p>

          <hr>

          <h2>Conditions financières</h2>
          <p>
            Prix de la licence : \(contract.price) \(escape(contract.currency.rawValue))<br>
            Mode de paiement : \(escape(contract.paymentMethod.rawValue))<br>
            Référence paiement : \(paymentRef)
          </p>

          <hr>

          <h2>Droits accordés</h2>
          <ul>\(rightsHTML)</ul>

          <hr>

          <h2>Limites d'utilisation</h2>
          <ul>
            <li>Streams autorisés : \(escape(streamsLabel))</li>
            <li>Distribution : \(escape(contract.licenseType.distributionLabel))</li>
            <li>Formats fournis : \(escape(contract.licenseType.formats))</li>
            <li>Durée de la licence : perpétuelle</li>
          </ul>

          <hr>

          <h2>Crédits obligatoires</h2>
          <p>
            L'Artiste s'engage à créditer le Producteur comme suit sur toutes les publications :<br>
            "<strong>\(escape(contract.producerAlias))</strong>"
          </p>

          <hr>

          <h2>Clauses additionnelles</h2>
          <p>\(clauses)</p>

          <hr>

          <h2>Signatures</h2>
          <div class="signatures">
            <p class="sign-line">Producteur : _______________________ &nbsp;&nbsp; Date : __________</p>
            <p class="sign-line">Artiste : &nbsp;&nbsp;_______________________ &nbsp;&nbsp; Date : __________</p>
          </div>

          <hr>
          <p class="footer">
            Contrat généré via BeatDeal · beatdeal.app<br>
            Référence : \(escape(contract.reference))
          </p>
        </body>
        </html>
        """
    }

    private static func escape(_ text: String) -> String {
        text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
}
