//
//  SceneKitRepresentableView.swift
//  ARKit_Examples
//
//  Created by Jacob Van Order on 12/11/22.
//

import SwiftUI
import ARKit

struct SceneKitRepresentableView: UIViewControllerRepresentable {
    typealias UIViewControllerType = SceneKitViewController
    
    func makeUIViewController(context: Context) -> SceneKitViewController {
        let sceneKitViewController = SceneKitViewController()
        return sceneKitViewController
    }

    func updateUIViewController(_ uiViewController: SceneKitViewController, context: Context) {
        
    }

}

struct SceneKitRepresentableView_Previews: PreviewProvider {
    static var previews: some View {
        SceneKitRepresentableView()
    }
}

class SceneKitViewController: UIViewController {
    let sceneView = ARSCNView(frame: .zero)
    var session: ARSession {  return sceneView.session }
    var asset: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up sceneView
        sceneView.frame = view.bounds
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(sceneView)
        sceneView.session.delegate = self
        sceneView.autoenablesDefaultLighting = true
        
        loadAsset(named: "teapot")
        addLight()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func loadAsset(named: String) {
        guard let path = Bundle.main.path(forResource: named, ofType: "obj") else { return }
        let url = URL(filePath: path)
        let scene = try? SCNScene(url: url)
        asset = scene?.rootNode.childNodes.first
        asset?.scale = SCNVector3(x: 0.03, y: 0.03, z: 0.03)
        asset?.castsShadow = true
        asset?.geometry?.materials.first?.lightingModel = .physicallyBased
    }
    
    func addLight() {
        let spotLight = SCNNode()
        spotLight.light = SCNLight()
        spotLight.scale = SCNVector3(1,1,1)
        spotLight.light?.intensity = 1000
        spotLight.castsShadow = true
        spotLight.position = SCNVector3Zero
        spotLight.light?.type = SCNLight.LightType.directional
        spotLight.light?.color = UIColor(red: 1.0, green: 1.0, blue: 0.9, alpha: 1.0)
        sceneView.scene.rootNode.addChildNode(spotLight)
    }
}

extension SceneKitViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard
            let planeAnchor = anchors.first(where: { $0 is ARPlaneAnchor }) as? ARPlaneAnchor,
            let asset = asset,
            asset.parent == nil else { return }
        asset.simdPosition = planeAnchor.transform.translation
        sceneView.scene.rootNode.addChildNode(asset)
    }
}

extension float4x4 {
    var translation: SIMD3<Float> {
        get {
            let translation = columns.3
            return [translation.x, translation.y, translation.z]
        }
        set(newValue) {
            columns.3 = [newValue.x, newValue.y, newValue.z, columns.3.w]
        }
    }
}
