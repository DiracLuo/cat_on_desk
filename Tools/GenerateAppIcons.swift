import AppKit
import Foundation

let rootURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let spriteURL = rootURL.appendingPathComponent("Resources/CatSprites/idle_00.png")
let outputPNG = rootURL.appendingPathComponent("Resources/AppIcon.png")
let iconsetURL = rootURL.appendingPathComponent("Resources/AppIcon.iconset")
let outputICNS = rootURL.appendingPathComponent("Resources/AppIcon.icns")
let outputICO = rootURL.appendingPathComponent("Windows/PetCompanion.Windows/app.ico")
let temp256PNG = rootURL.appendingPathComponent(".build/app-icon-256.png")

try FileManager.default.createDirectory(at: outputPNG.deletingLastPathComponent(), withIntermediateDirectories: true)
try FileManager.default.createDirectory(at: outputICO.deletingLastPathComponent(), withIntermediateDirectories: true)
try FileManager.default.createDirectory(at: temp256PNG.deletingLastPathComponent(), withIntermediateDirectories: true)

if FileManager.default.fileExists(atPath: iconsetURL.path) {
    try FileManager.default.removeItem(at: iconsetURL)
}

if FileManager.default.fileExists(atPath: outputICNS.path) {
    try FileManager.default.removeItem(at: outputICNS)
}

let icon = try drawAppIcon(spriteURL: spriteURL)
try writePNG(icon, to: outputPNG)

try FileManager.default.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

let iconsetSizes: [(name: String, pixels: Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

for iconSize in iconsetSizes {
    let destination = iconsetURL.appendingPathComponent(iconSize.name)
    try run("/usr/bin/sips", arguments: ["-z", "\(iconSize.pixels)", "\(iconSize.pixels)", outputPNG.path, "--out", destination.path])
}

try writeICNS(
    from: [
        ("icp4", iconsetURL.appendingPathComponent("icon_16x16.png")),
        ("icp5", iconsetURL.appendingPathComponent("icon_32x32.png")),
        ("icp6", iconsetURL.appendingPathComponent("icon_32x32@2x.png")),
        ("ic07", iconsetURL.appendingPathComponent("icon_128x128.png")),
        ("ic08", iconsetURL.appendingPathComponent("icon_128x128@2x.png")),
        ("ic09", iconsetURL.appendingPathComponent("icon_256x256@2x.png")),
        ("ic10", iconsetURL.appendingPathComponent("icon_512x512@2x.png"))
    ],
    to: outputICNS
)
try run("/usr/bin/sips", arguments: ["-z", "256", "256", outputPNG.path, "--out", temp256PNG.path])
try writeICO(fromPNG: temp256PNG, to: outputICO)

private func drawAppIcon(spriteURL: URL) throws -> NSImage {
    guard let cat = NSImage(contentsOf: spriteURL) else {
        throw NSError(domain: "GenerateAppIcons", code: 1, userInfo: [
            NSLocalizedDescriptionKey: "Missing cat sprite at \(spriteURL.path)"
        ])
    }

    let size = NSSize(width: 1024, height: 1024)
    let image = NSImage(size: size)
    image.lockFocus()

    NSColor.clear.setFill()
    NSRect(origin: .zero, size: size).fill()

    let backgroundRect = NSRect(x: 44, y: 44, width: 936, height: 936)
    let backgroundPath = NSBezierPath(roundedRect: backgroundRect, xRadius: 216, yRadius: 216)
    NSGraphicsContext.current?.saveGraphicsState()
    backgroundPath.addClip()
    let gradient = NSGradient(colors: [
        NSColor(calibratedRed: 1.0, green: 0.86, blue: 0.58, alpha: 1),
        NSColor(calibratedRed: 0.96, green: 0.58, blue: 0.36, alpha: 1)
    ])
    gradient?.draw(in: backgroundPath, angle: -90)
    NSGraphicsContext.current?.restoreGraphicsState()

    NSColor(calibratedWhite: 1.0, alpha: 0.25).setStroke()
    backgroundPath.lineWidth = 8
    backgroundPath.stroke()

    NSColor(calibratedWhite: 0.12, alpha: 0.14).setFill()
    NSBezierPath(ovalIn: NSRect(x: 260, y: 144, width: 504, height: 72)).fill()

    NSGraphicsContext.current?.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowOffset = NSSize(width: 0, height: -10)
    shadow.shadowBlurRadius = 18
    shadow.shadowColor = NSColor(calibratedWhite: 0.08, alpha: 0.24)
    shadow.set()
    cat.draw(in: NSRect(x: 108, y: 208, width: 808, height: 646), from: .zero, operation: .sourceOver, fraction: 1)
    NSGraphicsContext.current?.restoreGraphicsState()

    image.unlockFocus()
    return image
}

private func writePNG(_ image: NSImage, to url: URL) throws {
    guard
        let tiff = image.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiff),
        let png = bitmap.representation(using: .png, properties: [:])
    else {
        throw NSError(domain: "GenerateAppIcons", code: 2, userInfo: [
            NSLocalizedDescriptionKey: "Could not encode PNG at \(url.path)"
        ])
    }
    try png.write(to: url)
}

private func writeICO(fromPNG pngURL: URL, to icoURL: URL) throws {
    let png = try Data(contentsOf: pngURL)
    var data = Data()

    appendUInt16(0, to: &data)
    appendUInt16(1, to: &data)
    appendUInt16(1, to: &data)
    data.append(0)
    data.append(0)
    data.append(0)
    data.append(0)
    appendUInt16(1, to: &data)
    appendUInt16(32, to: &data)
    appendUInt32(UInt32(png.count), to: &data)
    appendUInt32(22, to: &data)
    data.append(png)

    try data.write(to: icoURL)
}

private func writeICNS(from entries: [(type: String, url: URL)], to icnsURL: URL) throws {
    var payload = Data()

    for entry in entries {
        let png = try Data(contentsOf: entry.url)
        guard let typeData = entry.type.data(using: .ascii), typeData.count == 4 else {
            throw NSError(domain: "GenerateAppIcons", code: 3, userInfo: [
                NSLocalizedDescriptionKey: "Invalid ICNS type \(entry.type)"
            ])
        }
        payload.append(typeData)
        appendUInt32BigEndian(UInt32(png.count + 8), to: &payload)
        payload.append(png)
    }

    var data = Data()
    data.append("icns".data(using: .ascii)!)
    appendUInt32BigEndian(UInt32(payload.count + 8), to: &data)
    data.append(payload)
    try data.write(to: icnsURL)
}

private func appendUInt16(_ value: UInt16, to data: inout Data) {
    data.append(UInt8(value & 0xff))
    data.append(UInt8((value >> 8) & 0xff))
}

private func appendUInt32(_ value: UInt32, to data: inout Data) {
    data.append(UInt8(value & 0xff))
    data.append(UInt8((value >> 8) & 0xff))
    data.append(UInt8((value >> 16) & 0xff))
    data.append(UInt8((value >> 24) & 0xff))
}

private func appendUInt32BigEndian(_ value: UInt32, to data: inout Data) {
    data.append(UInt8((value >> 24) & 0xff))
    data.append(UInt8((value >> 16) & 0xff))
    data.append(UInt8((value >> 8) & 0xff))
    data.append(UInt8(value & 0xff))
}

private func run(_ executable: String, arguments: [String]) throws {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: executable)
    process.arguments = arguments
    try process.run()
    process.waitUntilExit()

    if process.terminationStatus != 0 {
        throw NSError(domain: "GenerateAppIcons", code: Int(process.terminationStatus), userInfo: [
            NSLocalizedDescriptionKey: "\(executable) \(arguments.joined(separator: " ")) failed"
        ])
    }
}
