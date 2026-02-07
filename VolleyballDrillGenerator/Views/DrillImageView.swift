import SwiftUI

// MARK: - Drill Image View

/// Unified image component for displaying a drill's visual.
/// Priority order:
///   1. Remote animated GIF (if `drill.image` ends in .gif)
///   2. Bundled local image (if `drill.imageAsset` is non-empty)
///   3. Styled SF Symbol placeholder using the skill category icon
struct DrillImageView: View {
    let drill: Drill

    /// Display mode: `.hero` for the large detail image, `.thumbnail` for cards
    var mode: DisplayMode = .hero

    enum DisplayMode {
        case hero
        case thumbnail
    }

    var body: some View {
        Group {
            if drill.hasAnimatedImage, let url = drill.imageURL {
                // Animated GIF from remote URL
                gifView(url: url)
            } else if !drill.imageAsset.isEmpty,
                      let path = Bundle.main.path(forResource: drill.imageAsset,
                                                  ofType: "png",
                                                  inDirectory: "DrillImages"),
                      let uiImage = UIImage(contentsOfFile: path) {
                // Bundled local image from Resources/DrillImages
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                // Fallback: styled SF Symbol placeholder
                placeholderView
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: mode == .hero ? 220 : 60)
        .clipShape(RoundedRectangle(cornerRadius: mode == .hero ? 16 : 10))
        .overlay(
            RoundedRectangle(cornerRadius: mode == .hero ? 16 : 10)
                .stroke(Color(.systemGray4), lineWidth: 0.5)
        )
    }

    // MARK: - Sub-views

    /// Animated GIF loaded from a remote URL
    @ViewBuilder
    private func gifView(url: URL) -> some View {
        ZStack {
            Color(.systemGray6)
            CachedGIFImageView(url: url)

            // Small "GIF" badge in the corner
            if mode == .hero {
                VStack {
                    HStack {
                        Spacer()
                        Text("GIF")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.6), in: Capsule())
                            .padding(8)
                    }
                    Spacer()
                }
            }
        }
    }

    /// SF Symbol placeholder when no image is available
    private var placeholderView: some View {
        ZStack {
            Color(.systemGray6)

            VStack(spacing: 6) {
                Image(systemName: drill.skillCategory?.icon ?? "sportscourt")
                    .font(mode == .hero ? .largeTitle : .caption)
                    .foregroundColor(drill.skillCategory?.color ?? .gray)
                if mode == .hero {
                    Text(drill.skill)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
