//
//  HTMLTextHelper.swift
//  CoreAPIImpl
//

import Foundation

/// NASA's text fields can hold HTML (links, bold, entities). The app shows plain text: tags go, line breaks stay,
/// entities become their characters.
enum HTMLTextHelper {

    static func plainText(_ html: String) -> String {
        var text = html
            .replacing(/(?i)<br\s*\/?>|<\/p\s*>/, with: "\n")
            .replacing(/<[^>]*>/, with: "")
        for (entity, character) in entities {
            text = text.replacing(entity, with: character)
        }
        return text
            .replacing(/[ \t]+\n/, with: "\n")
            .replacing(/\n{3,}/, with: "\n\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// `&amp;` last, so "&amp;lt;" stays "&lt;" as written.
    private static let entities: [(String, String)] = [
        ("&nbsp;", " "),
        ("&quot;", "\""),
        ("&#39;", "'"),
        ("&apos;", "'"),
        ("&lt;", "<"),
        ("&gt;", ">"),
        ("&amp;", "&"),
    ]
}
