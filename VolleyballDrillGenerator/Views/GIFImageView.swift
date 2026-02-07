import SwiftUI
import UIKit
import ImageIO

// MARK: - GIF Image View

/// A SwiftUI wrapper around UIImageView that loads and displays
/// animated GIFs from a remote URL. Uses ImageIO to decode frames
/// and UIImageView's built-in animation support.
struct GIFImageView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        // Avoid re-downloading if already loaded for same URL
        if context.coordinator.loadedURL == url { return }
        context.coordinator.loadedURL = url

        // Load GIF data on a background queue
        DispatchQueue.global(qos: .userInitiated).async {
            guard let data = try? Data(contentsOf: url) else { return }
            guard let animatedImage = GIFImageView.animatedImage(from: data) else { return }

            DispatchQueue.main.async {
                uiView.image = animatedImage
            }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator {
        var loadedURL: URL?
    }

    // MARK: - GIF Decoding

    /// Decode GIF data into a UIImage with animation frames using ImageIO.
    static func animatedImage(from data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }

        let frameCount = CGImageSourceGetCount(source)
        guard frameCount > 1 else {
            // Single-frame image — return as-is
            return UIImage(data: data)
        }

        var frames: [UIImage] = []
        var totalDuration: Double = 0

        for i in 0..<frameCount {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else {
                continue
            }
            let frameDuration = GIFImageView.frameDuration(at: i, source: source)
            totalDuration += frameDuration
            frames.append(UIImage(cgImage: cgImage))
        }

        guard !frames.isEmpty else { return nil }

        return UIImage.animatedImage(with: frames, duration: totalDuration)
    }

    /// Extract the display duration for a single frame from the GIF metadata.
    static func frameDuration(at index: Int, source: CGImageSource) -> Double {
        let defaultDuration = 0.1

        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
              let gifDict = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any] else {
            return defaultDuration
        }

        // Prefer unclamped delay time, then clamped delay time
        if let unclamped = gifDict[kCGImagePropertyGIFUnclampedDelayTime] as? Double, unclamped > 0 {
            return unclamped
        }
        if let clamped = gifDict[kCGImagePropertyGIFDelayTime] as? Double, clamped > 0 {
            return clamped
        }

        return defaultDuration
    }
}

// MARK: - Cached GIF Image View

/// Wrapper that adds simple in-memory caching for GIF data
/// so the same URL isn't re-downloaded on every view appearance.
struct CachedGIFImageView: View {
    let url: URL

    var body: some View {
        GIFImageView(url: url)
    }
}
