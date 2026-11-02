import SceneKit
import SwiftUI
import UIKit

/// The only custom-rendered surface. Heartwood disc, sapwood band, and quartile wires share one SceneKit view.
struct GardenTrunkView: UIViewRepresentable {
    var saved: CGFloat
    var band: CGFloat
    var trying: CGFloat
    var lobes: Int
    var reached: [Bool]

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = context.coordinator.scene
        view.allowsCameraControl = false
        view.backgroundColor = DesignTokens.bgUI
        view.antialiasingMode = .none
        view.autoenablesDefaultLighting = false
        view.rendersContinuously = true
        view.isUserInteractionEnabled = false
        context.coordinator.installCamera()
        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        view.allowsCameraControl = false
        view.backgroundColor = DesignTokens.bgUI
        context.coordinator.scene.background.contents = DesignTokens.bgUI
        context.coordinator.rebuild(
            saved: saved,
            band: band,
            trying: trying,
            lobes: max(lobes, 3),
            reached: reached
        )
    }

    @MainActor
    final class Coordinator {
        let scene = SCNScene()
        let heart = SCNNode()
        let sap = SCNNode()
        var wires: [SCNNode] = []

        func installCamera() {
            let camera = SCNCamera()
            camera.usesOrthographicProjection = true
            camera.orthographicScale = 1.25
            let node = SCNNode()
            node.camera = camera
            node.position = SCNVector3(0, 3, 0)
            node.look(at: SCNVector3(0, 0, 0))
            scene.rootNode.addChildNode(node)
            scene.rootNode.addChildNode(heart)
            scene.rootNode.addChildNode(sap)
            for _ in 0..<4 {
                let wire = SCNNode()
                scene.rootNode.addChildNode(wire)
                wires.append(wire)
            }
            scene.background.contents = DesignTokens.bgUI
        }

        func rebuild(saved: CGFloat, band: CGFloat, trying: CGFloat, lobes: Int, reached: [Bool]) {
            let savedClamped = min(max(saved, 0), 1)
            let heartRadius = 0.26 + (0.64 * savedClamped)
            heart.geometry = disc(radius: heartRadius, lobes: lobes, wobble: 0, depth: 0.05)
            heart.geometry?.materials = [TrunkDither.material(TrunkDither.core)]
            heart.eulerAngles.x = -.pi / 2
            heart.position = SCNVector3(0, 0, 0)

            let extra = min(0.36, (band * 0.7) + (trying * 0.55))
            if extra > 0.02 {
                sap.isHidden = false
                sap.geometry = annulus(
                    inner: heartRadius + 0.02,
                    outer: heartRadius + 0.05 + extra,
                    lobes: lobes
                )
                sap.geometry?.materials = [TrunkDither.material(TrunkDither.band)]
                sap.eulerAngles.x = -.pi / 2
                sap.position = SCNVector3(0, 0.03, 0)
            } else {
                sap.isHidden = true
            }

            for index in 0..<wires.count {
                let fraction = CGFloat(index + 1) / 4
                let radius = 0.26 + (0.64 * fraction)
                let node = wires[index]
                node.geometry = annulus(inner: radius - 0.012, outer: radius + 0.012, lobes: 0)
                let on = index < reached.count && reached[index]
                node.geometry?.materials = [TrunkDither.solid(on ? DesignTokens.accentUI : DesignTokens.mutedUI)]
                node.eulerAngles.x = -.pi / 2
                node.position = SCNVector3(0, 0.08, 0)
            }
        }

        private func disc(radius: CGFloat, lobes: Int, wobble: CGFloat, depth: CGFloat) -> SCNShape {
            let path = UIBezierPath()
            let steps = 96
            let waveCount = CGFloat(max(lobes, 3))
            for step in 0...steps {
                let turn = CGFloat(step) / CGFloat(steps) * .pi * 2
                let wave = 1 + (wobble * sin(turn * waveCount))
                let point = CGPoint(x: cos(turn) * radius * wave, y: sin(turn) * radius * wave)
                if step == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            path.close()
            return SCNShape(path: path, extrusionDepth: depth)
        }

        private func annulus(inner: CGFloat, outer: CGFloat, lobes: Int) -> SCNShape {
            let path = UIBezierPath()
            let steps = 96
            let waveCount = CGFloat(max(lobes, 3))
            let wobble: CGFloat = lobes > 0 ? 0.07 : 0
            for step in 0...steps {
                let turn = CGFloat(step) / CGFloat(steps) * .pi * 2
                let wave = 1 + (wobble * sin(turn * waveCount))
                let point = CGPoint(x: cos(turn) * outer * wave, y: sin(turn) * outer * wave)
                if step == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            path.close()
            let hole = UIBezierPath()
            for step in 0...steps {
                let turn = CGFloat(steps - step) / CGFloat(steps) * .pi * 2
                let point = CGPoint(x: cos(turn) * inner, y: sin(turn) * inner)
                if step == 0 {
                    hole.move(to: point)
                } else {
                    hole.addLine(to: point)
                }
            }
            hole.close()
            path.append(hole)
            path.usesEvenOddFillRule = true
            let shape = SCNShape(path: path, extrusionDepth: 0.04)
            return shape
        }
    }
}

@MainActor
private enum TrunkDither {
    static let core = texture(paper: DesignTokens.surfaceUI, ink: DesignTokens.inkUI, threshold: 6)
    static let band = texture(paper: DesignTokens.surfaceUI, ink: DesignTokens.accentUI, threshold: 8)

    static func material(_ image: UIImage) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = image
        material.lightingModel = .constant
        material.isDoubleSided = true
        return material
    }

    static func solid(_ color: UIColor) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.lightingModel = .constant
        material.isDoubleSided = true
        return material
    }

    private static func texture(paper: UIColor, ink: UIColor, threshold: Int) -> UIImage {
        let cells = 16
        let cell = 4
        let side = cells * cell
        let bayer = [
            0, 8, 2, 10,
            12, 4, 14, 6,
            3, 11, 1, 9,
            15, 7, 13, 5
        ]
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: side, height: side))
        return renderer.image { context in
            paper.setFill()
            context.fill(CGRect(x: 0, y: 0, width: side, height: side))
            ink.setFill()
            for row in 0..<cells {
                for column in 0..<cells {
                    let sample = bayer[(row % 4) * 4 + (column % 4)]
                    guard sample > threshold else { continue }
                    let origin = CGPoint(x: column * cell + 1, y: row * cell + 1)
                    context.fill(CGRect(origin: origin, size: CGSize(width: 2, height: 2)))
                }
            }
        }
    }
}
