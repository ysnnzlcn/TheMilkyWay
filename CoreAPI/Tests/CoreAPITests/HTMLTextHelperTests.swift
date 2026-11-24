//
//  HTMLTextHelperTests.swift
//  CoreAPITests
//

import Testing
@testable import CoreAPIImpl

struct HTMLTextHelperTests {

    @Test(arguments: [
        // From a real description.
        (
            #"To learn more go to: <a href="http://www.nasa.gov/lro" rel="nofollow">www.nasa.gov/lro</a>"#,
            "To learn more go to: www.nasa.gov/lro"
        ),
        ("<b>Credit:</b> NASA &amp; ESA", "Credit: NASA & ESA"),
        ("Line one<br>Line two<BR />Line three", "Line one\nLine two\nLine three"),
        ("<p>First</p><p>Second</p>", "First\nSecond"),
        ("A &quot;quoted&quot; &#39;word&#39;&nbsp;here", "A \"quoted\" 'word' here"),
        ("Written as &amp;lt;", "Written as &lt;"),
        ("  Plain text, no HTML.  ", "Plain text, no HTML."),
        ("One<br><br><br><br>Two", "One\n\nTwo"),
    ])
    func plainText(html: String, expected: String) {
        #expect(HTMLTextHelper.plainText(html) == expected)
    }
}
