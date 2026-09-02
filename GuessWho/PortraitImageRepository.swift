import Foundation
import ImageIO
import UIKit

@MainActor
final class PortraitImageRepository: ObservableObject {
    @Published private(set) var loadedAssetNames: Set<String> = []

    private let bundle: Bundle
    private let cache = NSCache<NSString, UIImage>()
    private var requestedAssetNames: Set<String> = []
    private static let thumbnailPixelSize = 512

    init(bundle: Bundle = .main) {
        self.bundle = bundle
        // A bounded cache prevents a full roster from consuming the device memory budget.
        cache.countLimit = 24
        cache.totalCostLimit = 32 * 1024 * 1024
    }

    func image(for character: Character) -> UIImage? {
        cache.object(forKey: character.portraitAssetName as NSString)
    }

    func preloadIfNeeded(for characters: [Character]) {
        let assetNames = Set(characters.map(\.portraitAssetName)).subtracting(requestedAssetNames)
        guard !assetNames.isEmpty else { return }

        requestedAssetNames.formUnion(assetNames)

        let bundle = bundle
        let assetNamesToLoad = Array(assetNames)

        DispatchQueue.global(qos: .utility).async { [weak self] in
            for assetName in assetNamesToLoad {
                autoreleasepool {
                    guard
                        let url = bundle.url(
                            forResource: assetName,
                            withExtension: "png",
                            subdirectory: "CharacterPortraits"
                        ),
                        let image = Self.downsampledImage(at: url)
                    else {
                        return
                    }

                    let cost = image.cgImage.map { $0.bytesPerRow * $0.height } ?? 0
                    DispatchQueue.main.async {
                        guard let self else { return }
                        self.cache.setObject(image, forKey: assetName as NSString, cost: cost)
                        self.loadedAssetNames.insert(assetName)
                    }
                }
            }
        }
    }

    nonisolated private static func downsampledImage(at url: URL) -> UIImage? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return nil
        }

        let options: CFDictionary = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: thumbnailPixelSize,
            kCGImageSourceShouldCacheImmediately: true
        ] as CFDictionary

        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else {
            return nil
        }

        return UIImage(cgImage: image)
    }
}
