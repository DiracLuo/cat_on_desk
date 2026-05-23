import AppKit
import SpriteKit

enum PetAnimation: String {
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

final class CatSpriteLibrary {
    static let shared = CatSpriteLibrary()

    private var cache: [PetAnimation: [SKTexture]] = [:]
    private var warnedMissingAssets = Set<String>()

    func frames(for animation: PetAnimation) -> [SKTexture] {
        if let cached = cache[animation] {
            return cached
        }

        let textures = (0..<animation.frameCount).compactMap { index in
            texture(animation: animation, index: index)
        }
        if textures.count != animation.frameCount {
            print("Warning: loaded \(textures.count)/\(animation.frameCount) frames for \(animation.rawValue)")
        }
        cache[animation] = textures
        return textures
    }

    private func texture(animation: PetAnimation, index: Int) -> SKTexture? {
        let name = "\(animation.rawValue)_\(String(format: "%02d", index))"
        guard let url = Bundle.main.url(forResource: name, withExtension: "png", subdirectory: "CatSprites"),
              let image = NSImage(contentsOf: url) else {
            if !warnedMissingAssets.contains(name) {
                print("Warning: missing cat sprite asset CatSprites/\(name).png")
                warnedMissingAssets.insert(name)
            }
            return nil
        }

        let texture = SKTexture(image: image)
        texture.filteringMode = .linear
        return texture
    }
}
