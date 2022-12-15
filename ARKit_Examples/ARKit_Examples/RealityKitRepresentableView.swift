//
//  RealityKitRepresentableView.swift
//  ARKit_Examples
//
//  Created by Jacob Van Order on 12/11/22.
//

import SwiftUI
import Combine
import RealityKit
import ARKit

struct RealityKitRepresentableView: UIViewControllerRepresentable {
    typealias UIViewControllerType = RealityKitViewController
    
    func makeUIViewController(context: Context) -> RealityKitViewController {
        let realityKitViewController = RealityKitViewController()
        return realityKitViewController
    }
    
    func updateUIViewController(_ uiViewController: RealityKitViewController, context: Context) {
        
    }
}

struct RealityKitRepresentableView_Previews: PreviewProvider {
    static var previews: some View {
        RealityKitRepresentableView()
    }
}

class RealityKitViewController: UIViewController {
    let arView = ARView(frame: .zero)
    var session: ARSession {  return arView.session }
    var asset: Entity?
    lazy var light: PointLight = {
        let pointLight = PointLight()
        pointLight.light.color = .white
        pointLight.light.intensity = 1000000
        pointLight.light.attenuationRadius = 7.0
        pointLight.position = [3, 3, 3]
        return pointLight
    }()
    var cancellable = Set<AnyCancellable>()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up sceneView
        arView.frame = view.bounds
        arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(arView)
        arView.session.delegate = self
        
        loadAsset(named: "teapot")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func loadAsset(named: String) {
        guard let path = Bundle.main.path(forResource: named, ofType: "usdz") else { return }
        let url = URL(filePath: path)
        let _ = Entity.loadAsync(contentsOf: url)
            .sink { response in
                switch response {
                case .failure(let error):
                    print(error)
                case .finished:
                    print("done!")
                }
            } receiveValue: { entity in
                self.asset = entity
                self.asset?.scale = SIMD3(x: 0.03, y: 0.03, z: 0.03)
            }
            .store(in: &cancellable)
    }
}

extension RealityKitViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let planeAnchor = anchors.first(where: { $0 is ARPlaneAnchor }) as? ARPlaneAnchor,
              let asset = self.asset,
        asset.parent == nil else { return }
        let anchor = AnchorEntity(anchor: planeAnchor)
        anchor.addChild(asset)
        anchor.addChild(light)
        self.arView.scene.addAnchor(anchor)
    }
}
