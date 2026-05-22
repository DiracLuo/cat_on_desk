import AppKit

enum SpriteAction: String, CaseIterable {
    case walk
    case idle
    case sleep
    case stretch
    case meow

    var frameCount: Int {
        switch self {
        case .walk: return 4
        case .idle: return 3
        case .sleep: return 4
        case .stretch: return 4
        case .meow: return 4
        }
    }
}

let outputURL = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? "Resources/CatSprites")
try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)

for action in SpriteAction.allCases {
    for frame in 0..<action.frameCount {
        let image = drawCat(action: action, frame: frame)
        let fileURL = outputURL.appendingPathComponent("\(action.rawValue)_\(String(format: "%02d", frame)).png")
        try writePNG(image, to: fileURL)
    }
}

private func drawCat(action: SpriteAction, frame: Int) -> NSImage {
    let size = NSSize(width: 160, height: 128)
    let image = NSImage(size: size)
    image.lockFocus()
    NSColor.clear.setFill()
    NSRect(origin: .zero, size: size).fill()

    let ctx = NSGraphicsContext.current!.cgContext
    ctx.translateBy(x: 0, y: size.height)
    ctx.scaleBy(x: 1, y: -1)

    let phase = CGFloat(frame) / CGFloat(max(action.frameCount, 1))
    let bounce = abs(sin(phase * .pi * 2)) * 3
    let bodyColor = NSColor(calibratedRed: 1.0, green: 0.72, blue: 0.42, alpha: 1)
    let lightBody = NSColor(calibratedRed: 1.0, green: 0.79, blue: 0.52, alpha: 1)
    let outline = NSColor(calibratedRed: 0.33, green: 0.18, blue: 0.09, alpha: 1)
    let stripe = NSColor(calibratedRed: 0.74, green: 0.41, blue: 0.2, alpha: 1)

    var origin = CGPoint(x: 80, y: 67 - bounce)
    var body = CGRect(x: origin.x - 44, y: origin.y - 22, width: 88, height: 46)
    var headCenter = CGPoint(x: origin.x + 43, y: origin.y - 14)
    var headRadius = CGSize(width: 25, height: 23)
    var tailLift: CGFloat = -18
    var legSwing = sin(phase * .pi * 2) * 6
    var eyesClosed = false
    var mouthOpen = false
    var showBubble = false

    switch action {
    case .idle:
        origin.y += sin(phase * .pi * 2) * 1.5
        body.origin.y = origin.y - 22
        headCenter.y += sin(phase * .pi * 2) * 1.2
        eyesClosed = frame == 1
        tailLift = -14 + sin(phase * .pi * 2) * 4
        legSwing = 0
    case .sleep:
        body = CGRect(x: 44, y: 65, width: 76, height: 36)
        headCenter = CGPoint(x: 107, y: 62)
        headRadius = CGSize(width: 23, height: 20)
        tailLift = 4
        eyesClosed = true
        legSwing = 0
    case .stretch:
        body = CGRect(x: 34, y: 62 - CGFloat(frame), width: 96, height: 38)
        headCenter = CGPoint(x: 126, y: 73 + CGFloat(frame))
        headRadius = CGSize(width: 24, height: 22)
        tailLift = -30 - CGFloat(frame * 2)
        legSwing = CGFloat(frame * 2)
        mouthOpen = frame >= 2
    case .meow:
        mouthOpen = frame % 2 == 0
        showBubble = frame >= 1
        tailLift = -20 + sin(phase * .pi * 2) * 5
    case .walk:
        break
    }

    drawTail(ctx: ctx, from: CGPoint(x: body.minX + 10, y: body.midY - 4), lift: tailLift, outline: outline, body: bodyColor)
    drawBody(ctx: ctx, rect: body, fill: bodyColor, outline: outline)
    drawStripes(ctx: ctx, body: body, color: stripe)

    if action != .sleep {
        drawLeg(ctx: ctx, at: CGPoint(x: body.midX - 23, y: body.maxY - 5), swing: -legSwing, outline: outline)
        drawLeg(ctx: ctx, at: CGPoint(x: body.midX + 20, y: body.maxY - 5), swing: legSwing, outline: outline)
    }

    drawHead(ctx: ctx, center: headCenter, radius: headRadius, fill: lightBody, outline: outline)
    drawEars(ctx: ctx, center: headCenter, outline: outline, fill: lightBody)
    drawFace(ctx: ctx, center: headCenter, eyesClosed: eyesClosed, mouthOpen: mouthOpen, outline: outline)

    if action == .sleep {
        drawSleepMarks(ctx: ctx, frame: frame)
    }
    if showBubble {
        drawMeowBubble(ctx: ctx, frame: frame)
    }

    image.unlockFocus()
    return image
}

private func drawBody(ctx: CGContext, rect: CGRect, fill: NSColor, outline: NSColor) {
    let path = CGPath(roundedRect: rect, cornerWidth: 23, cornerHeight: 23, transform: nil)
    ctx.addPath(path)
    ctx.setFillColor(fill.cgColor)
    ctx.fillPath()
    ctx.addPath(path)
    ctx.setStrokeColor(outline.cgColor)
    ctx.setLineWidth(3)
    ctx.strokePath()
}

private func drawTail(ctx: CGContext, from point: CGPoint, lift: CGFloat, outline: NSColor, body: NSColor) {
    let path = CGMutablePath()
    path.move(to: point)
    path.addCurve(
        to: CGPoint(x: point.x - 30, y: point.y + lift),
        control1: CGPoint(x: point.x - 18, y: point.y - 2),
        control2: CGPoint(x: point.x - 34, y: point.y + lift + 8)
    )
    ctx.addPath(path)
    ctx.setStrokeColor(outline.cgColor)
    ctx.setLineWidth(13)
    ctx.setLineCap(.round)
    ctx.strokePath()
    ctx.addPath(path)
    ctx.setStrokeColor(body.cgColor)
    ctx.setLineWidth(8)
    ctx.strokePath()
}

private func drawLeg(ctx: CGContext, at point: CGPoint, swing: CGFloat, outline: NSColor) {
    let rect = CGRect(x: point.x - 5 + swing * 0.2, y: point.y, width: 11, height: 25)
    let path = CGPath(roundedRect: rect, cornerWidth: 5, cornerHeight: 5, transform: nil)
    ctx.addPath(path)
    ctx.setFillColor(NSColor(calibratedRed: 0.96, green: 0.58, blue: 0.28, alpha: 1).cgColor)
    ctx.fillPath()
    ctx.addPath(path)
    ctx.setStrokeColor(outline.cgColor)
    ctx.setLineWidth(2)
    ctx.strokePath()
}

private func drawHead(ctx: CGContext, center: CGPoint, radius: CGSize, fill: NSColor, outline: NSColor) {
    let rect = CGRect(x: center.x - radius.width, y: center.y - radius.height, width: radius.width * 2, height: radius.height * 2)
    ctx.addEllipse(in: rect)
    ctx.setFillColor(fill.cgColor)
    ctx.fillPath()
    ctx.addEllipse(in: rect)
    ctx.setStrokeColor(outline.cgColor)
    ctx.setLineWidth(3)
    ctx.strokePath()
}

private func drawEars(ctx: CGContext, center: CGPoint, outline: NSColor, fill: NSColor) {
    for offset in [-15.0, 13.0] {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: center.x + offset - 9, y: center.y - 14))
        path.addLine(to: CGPoint(x: center.x + offset, y: center.y - 36))
        path.addLine(to: CGPoint(x: center.x + offset + 15, y: center.y - 15))
        path.closeSubpath()
        ctx.addPath(path)
        ctx.setFillColor(fill.cgColor)
        ctx.fillPath()
        ctx.addPath(path)
        ctx.setStrokeColor(outline.cgColor)
        ctx.setLineWidth(3)
        ctx.strokePath()
    }
}

private func drawFace(ctx: CGContext, center: CGPoint, eyesClosed: Bool, mouthOpen: Bool, outline: NSColor) {
    ctx.setStrokeColor(outline.cgColor)
    ctx.setFillColor(NSColor(calibratedWhite: 0.08, alpha: 1).cgColor)
    ctx.setLineWidth(2)

    for x in [-9.0, 8.0] {
        if eyesClosed {
            ctx.move(to: CGPoint(x: center.x + x - 4, y: center.y - 4))
            ctx.addLine(to: CGPoint(x: center.x + x + 4, y: center.y - 4))
            ctx.strokePath()
        } else {
            ctx.addEllipse(in: CGRect(x: center.x + x - 2.5, y: center.y - 7, width: 5, height: 6))
            ctx.fillPath()
        }
    }

    ctx.setFillColor(NSColor(calibratedRed: 0.78, green: 0.27, blue: 0.31, alpha: 1).cgColor)
    ctx.addEllipse(in: CGRect(x: center.x - 3, y: center.y, width: 7, height: 5))
    ctx.fillPath()

    if mouthOpen {
        ctx.setFillColor(NSColor(calibratedRed: 0.5, green: 0.12, blue: 0.16, alpha: 1).cgColor)
        ctx.addEllipse(in: CGRect(x: center.x - 4, y: center.y + 7, width: 9, height: 10))
        ctx.fillPath()
    } else {
        ctx.move(to: CGPoint(x: center.x, y: center.y + 5))
        ctx.addQuadCurve(to: CGPoint(x: center.x - 8, y: center.y + 8), control: CGPoint(x: center.x - 4, y: center.y + 11))
        ctx.move(to: CGPoint(x: center.x, y: center.y + 5))
        ctx.addQuadCurve(to: CGPoint(x: center.x + 8, y: center.y + 8), control: CGPoint(x: center.x + 4, y: center.y + 11))
        ctx.strokePath()
    }
}

private func drawStripes(ctx: CGContext, body: CGRect, color: NSColor) {
    ctx.setStrokeColor(color.cgColor)
    ctx.setLineWidth(3)
    ctx.setLineCap(.round)
    for x in [body.midX - 20, body.midX, body.midX + 20] {
        ctx.move(to: CGPoint(x: x, y: body.minY + 6))
        ctx.addLine(to: CGPoint(x: x - 5, y: body.minY + 18))
        ctx.strokePath()
    }
}

private func drawSleepMarks(ctx: CGContext, frame: Int) {
    let text = NSString(string: frame % 2 == 0 ? "Z" : "z")
    text.draw(
        at: CGPoint(x: 120, y: 22),
        withAttributes: [
            .font: NSFont.boldSystemFont(ofSize: frame % 2 == 0 ? 22 : 17),
            .foregroundColor: NSColor(calibratedWhite: 0.25, alpha: 0.8)
        ]
    )
}

private func drawMeowBubble(ctx: CGContext, frame: Int) {
    let rect = CGRect(x: 104, y: 20, width: 42, height: 24)
    let path = CGPath(roundedRect: rect, cornerWidth: 12, cornerHeight: 12, transform: nil)
    ctx.addPath(path)
    ctx.setFillColor(NSColor(calibratedWhite: 1, alpha: 0.9).cgColor)
    ctx.fillPath()
    ctx.addPath(path)
    ctx.setStrokeColor(NSColor(calibratedWhite: 0.2, alpha: 0.75).cgColor)
    ctx.setLineWidth(2)
    ctx.strokePath()

    let text = NSString(string: frame % 2 == 0 ? "喵" : "喵!")
    text.draw(
        at: CGPoint(x: 113, y: 24),
        withAttributes: [
            .font: NSFont.boldSystemFont(ofSize: 13),
            .foregroundColor: NSColor(calibratedWhite: 0.1, alpha: 1)
        ]
    )
}

private func writePNG(_ image: NSImage, to url: URL) throws {
    guard
        let tiff = image.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiff),
        let png = bitmap.representation(using: .png, properties: [:])
    else {
        throw NSError(domain: "GenerateCatSprites", code: 1)
    }
    try png.write(to: url)
}
