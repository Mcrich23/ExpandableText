//
//  ExpandableText.swift
//  ExpandableText
//
//  Created by ned on 23/02/23.
//

import Foundation
import SwiftUI

/**
An expandable text view that displays a truncated version of its contents with a "show more" button that expands the view to show the full contents.

 To create a new ExpandableText view, use the init method and provide the initial text string as a parameter. The text string will be automatically trimmed of any leading or trailing whitespace and newline characters.

Example usage with default parameters:
 ```swift
ExpandableText("Lorem ipsum dolor sit amet, consectetur adipiscing elit...")
    .font(.body)
    .foregroundColor(.primary)
    .lineLimit(3)
    .moreButtonText("more")
    .moreButtonColor(.accentColor)
    .expandAnimation(.default)
    .trimMultipleNewlinesWhenTruncated(true)
 ```
*/
public struct ExpandableText: View {

    @State private var isExpanded: Bool = false
    @State private var isTruncated: Bool = false

    @State private var intrinsicSize: CGSize = .zero
    @State private var truncatedSize: CGSize = .zero
    @State private var moreTextSize: CGSize = .zero
    
    private let text: NSAttributedString
    internal var font: Font = .body
    internal var color: Color = .primary
    internal var lineLimit: Int = 3
    internal var moreButtonText: String = "more"
    internal var moreButtonFont: Font?
    internal var moreButtonColor: Color = .accentColor
    internal var expandAnimation: Animation = .default
    internal var collapseEnabled: Bool = false
    internal var trimMultipleNewlinesWhenTruncated: Bool = true
    
    /**
     Initializes a new `ExpandableText` instance with the specified text string, trimmed of any leading or trailing whitespace and newline characters.
     - Parameter text: The initial text string to display in the `ExpandableText` view.
     - Returns: A new `ExpandableText` instance with the specified text string and trimming applied.
     */
    public init(_ text: NSAttributedString) {
        self.text = text
    }
    
    public init(_ text: String) {
        self.text = NSAttributedString(string: text.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    public var body: some View {
        content
            .lineLimit(isExpanded ? nil : lineLimit)
            .applyingTruncationMask(size: moreTextSize, enabled: shouldShowMoreButton)
            .readSize { size in
                truncatedSize = size
                isTruncated = truncatedSize != intrinsicSize
            }
            .background(
                content
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .hidden()
                    .readSize { size in
                        intrinsicSize = size
                        isTruncated = truncatedSize != intrinsicSize
                    }
            )
            .background(
                Text(moreButtonText)
                    .font(moreButtonFont ?? font)
                    .hidden()
                    .readSize { moreTextSize = $0 }
            )
            .contentShape(Rectangle())
            .onTapGesture {
                if (isExpanded && collapseEnabled) ||
                     shouldShowMoreButton {
                    withAnimation(expandAnimation) { isExpanded.toggle() }
                }
            }
            .modifier(OverlayAdapter(alignment: .trailingLastTextBaseline, view: {
                if shouldShowMoreButton {
                    Button {
                        withAnimation(expandAnimation) { isExpanded.toggle() }
                    } label: {
                        Text(moreButtonText)
                            .font(moreButtonFont ?? font)
                            .foregroundColor(moreButtonColor)
                    }
                }
            }))
    }
    
    private var textView: some View {
        if #available(iOS 15, *) {
            Text(AttributedString(
                trimMultipleNewlinesWhenTruncated
                ? (shouldShowMoreButton ? textTrimmingDoubleNewlines : text)
                : text
            ))
        } else {
            Text(
                trimMultipleNewlinesWhenTruncated
                ? (shouldShowMoreButton ? textTrimmingDoubleNewlines.string : text.string)
                : text.string
            )
        }
    }
    
    private var content: some View {
        textView
        .font(font)
        .foregroundColor(color)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var shouldShowMoreButton: Bool {
        !isExpanded && isTruncated
    }
    
    private var textTrimmingDoubleNewlines: NSAttributedString {
        text//.replacingOccurrences(of: #"\n\s*\n"#, with: "\n", options: .regularExpression)
    }
}
