import Foundation
import UIKit

@MainActor
final class PortraitImageRepository: ObservableObject {
    @Published private(set) var loadedAssetNames: Set<String> = []

    private let bundle: Bundle
    private let cache = NSCache<NSString, UIImage>()
    private var requestedAssetNames: Set<String> = []

    init(bundle: Bundle = .main) {
        self.bundle = bundle
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

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var loadedImages: [(String, UIImage)] = []
            loadedImages.reserveCapacity(assetNamesToLoad.count)

            for assetName in assetNamesToLoad {
                autoreleasepool {
                    guard
                        let url = bundle.url(
                            forResource: assetName,
                            withExtension: "png",
                            subdirectory: "CharacterPortraits"
                        ),
                        let image = UIImage(contentsOfFile: url.path)
                    else {
                        return
                    }

                    loadedImages.append((assetName, image))
                }
            }

            DispatchQueue.main.async {
                guard let self else { return }

                for (assetName, image) in loadedImages {
                    self.cache.setObject(image, forKey: assetName as NSString)
                    self.loadedAssetNames.insert(assetName)
                }
            }
        }
    }
}
