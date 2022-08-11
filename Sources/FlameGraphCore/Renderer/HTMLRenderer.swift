import Foundation

public class HTMLRenderer: BaseRenderer, Renderer {
    public static func render(graph: CallGraphNode) -> String {
        let maxDepth = CGFloat(graph.maxDepth)
        let cellHeight: CGFloat = 56
        let rect = CGRect(origin: .zero, size: CGSize(width: 10000, height: cellHeight * maxDepth))
        return """
        <html>
            <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">
            <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
            <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>
            <style>
                html, body { height: \(rect.height)px; }
                div {
                    color: white;
                    position: absolute;
                    overflow-x: scroll;
                    overflow-y: hidden
                }
                .popover {
                    z-index: 1;
                    width: 300px;
                    height: 70px;
                }
                .popover-content {
                    color: black;
                }
            </style>
            <body>
                \(divs(for: [graph], y: 0, x: 0, maxPercentage: graph.symbol.percentage, height: cellHeight, totalHeight: rect.height).joined(separator: "\n"))
            </body>
            <script>
            $(document).ready(function(){
                $('[data-toggle="popover"]').popover();   
            });
            </script>
        </html>
        """
    }

    private static func divs(for nodes: [CallGraphNode], y: CGFloat, x: CGFloat, maxPercentage _: Float, height: CGFloat, totalHeight: CGFloat) -> [String] {
        let xSpacing: CGFloat = 1
        let ySpacing: CGFloat = 1
        var currentX: CGFloat = x

        return nodes.map { node in

            let width = CGFloat(node.symbol.percentage * 150)
            let rect = CGRect(x: currentX, y: totalHeight - y, width: width, height: height)

            let childDivs = divs(for: node.subNodes, y: y + height + ySpacing, x: currentX, maxPercentage: node.symbol.percentage, height: height, totalHeight: totalHeight).reduce([], +)
            let color = colors.randomElement()!.hex
            let position: CGPoint = rect.origin
            let size: CGSize = rect.size
            let div = """
            <div style=\"background-color:\(color);top: \(position.y)px;left:\(position.x)px;width: \(size.width)px;height:\(size.height)px; font-size:14;\" 
                data-toggle=\"popover\" data-content=\"\(text(for: node))\">
                    <p>\(text(for: node))</p>
            </div>
            """
            currentX = rect.maxX + xSpacing
            return div + childDivs
        }
    }
}

extension String: RenderTarget {
    public func write(to url: URL) throws {
        try write(to: url, atomically: true, encoding: .utf8)
    }
}
