//
//  LaTeXView.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/8/24.
//

import SwiftUI
import WebKit

#if os(macOS)

struct LaTeXView: NSViewRepresentable {
    let latex: String
    @Binding var size: CGSize  // Bindable size for dynamic updates
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: LaTeXView

        init(parent: LaTeXView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Measure the content height using JavaScript
            webView.evaluateJavaScript("document.getElementById('math-content').offsetWidth") { width, error in
                webView.evaluateJavaScript("document.getElementById('math-content').offsetHeight") { height, error in
                    if let width = width as? CGFloat, let height = height as? CGFloat {
                        DispatchQueue.main.async {
                            self.parent.size = CGSize(width: width, height: height)
                        }
                    }
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        
        // Allow JavaScript
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        webView.configuration.defaultWebpagePreferences = preferences
        
        // Ensure file access (for offline MathJax or resources)
        webView.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/3.2.2/es5/tex-mml-chtml.js"></script>
            <style>
                body {
                    margin: 0;
                    padding: 0;
                    font-size: 3.5em;
                    background-color: transparent;
                }
                #math-content {
                    display: inline-block;
                    text-align: center;
                }
            </style>
        </head>
        <body>
            <div id="math-content">\\[\(latex)\\]</div>
            <script>
                MathJax.typeset();
            </script>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }
}

#elseif os(iOS)
struct LaTeXView: UIViewRepresentable {
    let latex: String
    @Binding var size: CGSize  // Bindable size for dynamic updates

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: LaTeXView

        init(parent: LaTeXView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Measure the content height using JavaScript
            webView.evaluateJavaScript("document.getElementById('math-content').offsetWidth") { width, error in
                webView.evaluateJavaScript("document.getElementById('math-content').offsetHeight") { height, error in
                    if let width = width as? CGFloat, let height = height as? CGFloat {
                        DispatchQueue.main.async {
                            self.parent.size = CGSize(width: width, height: height)
                        }
                    }
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.gestureRecognizers = nil
        webView.isUserInteractionEnabled = false
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = .clear //Transparent background
        webView.scrollView.isScrollEnabled = false  // Disable scrolling
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <script id="MathJax-script" async
                      src="https://cdn.jsdelivr.net/npm/mathjax@3.0.1/es5/tex-mml-chtml.js">
              </script>
            <style>
                body {
                    margin: 0;
                    padding: 0;
                    font-size: 3.5em;
                    background-color: transparent;
                }
                #math-content {
                    display: inline-block;
                    text-align: center;
                }
            </style>
        </head>
        <body>
            <div id="math-content">\\[\(latex)\\]</div>
            <script>
                MathJax.typeset();
            </script>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }
}
#endif

#Preview {
    @Previewable @State var size = CGSize(width: 1, height: 1)
    GeometryReader { geometry in
        LaTeXView(latex: "a^2", size: $size)
            .offset(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
            .frame(width: size.width, height: size.height)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
