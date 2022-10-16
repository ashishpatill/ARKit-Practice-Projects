//
//  ViewController.swift
//  World Tracking
//
//  Created by Ashish Pisey on 24/04/22.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    let configuration =  ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.session.run(configuration)
    }
    
    @IBAction func add(_ sender: Any) {
        let node = SCNNode()
        //node.geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        //node.geometry = SCNCapsule.init(capRadius: 0.1, height: 0.2)
        //node.geometry = SCNCone(topRadius: 0.1, bottomRadius: 0.5, height: 0.3)
        //node.geometry = SCNCylinder(radius: 0.1, height: 0.3)
        //node.geometry = SCNSphere(radius: 0.1)
        //node.geometry = SCNTube(innerRadius: 0.1, outerRadius: 0.1, height: 0.3)
        //node.geometry = SCNTorus(ringRadius: 0.3, pipeRadius: 0.1) // piperadius should be biggerr than pipe radius
        //node.geometry = SCNPlane(width: 0.2, height: 0.1)
        node.geometry = SCNPyramid(width: 0.1, height: 0.1, length: 0.1)
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
        node.position = SCNVector3(0, 0, -0.5)
        node.eulerAngles = SCNVector3(Float(180.degreeToRadians), 0, 0)
        node.geometry?.firstMaterial?.specular.contents = UIColor.white
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    
    @IBAction func reset(_ sender: Any) {
        resetSession()
    }

    private func resetSession() {
        self.sceneView.session.pause()
        self.sceneView.scene.rootNode.enumerateChildNodes { node, _ in
            node.removeFromParentNode()
        }
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}

extension Int {
    var degreeToRadians: Double { return Double(self) * .pi/180 }
}
