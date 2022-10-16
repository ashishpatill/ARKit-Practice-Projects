//
//  ViewController.swift
//  ARDrawing
//
//  Created by Ashish Pisey on 07/05/22.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    @IBOutlet weak var btnDraw: UIButton!
    @IBOutlet weak var btnReset: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.sceneView.debugOptions = [.showWorldOrigin]
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.showsStatistics = true
        self.sceneView.delegate = self
        self.sceneView.session.run(configuration)
    }

    @IBAction func draw() {
        
    }
    
    @IBAction func reset(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.sceneView.scene.rootNode.enumerateChildNodes { node, _ in
               node.removeFromParentNode()
            }
        }
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        print("rendering")
        guard let pointOfView = sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(-transform.m41, -transform.m42, -transform.m43)
        let currentPosition = orientation + location
        
        DispatchQueue.main.async {
            if self.btnDraw.isHighlighted {
                let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.01))
                sphereNode.position = currentPosition
                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
                self.sceneView.scene.rootNode.addChildNode(sphereNode)
            } else {
                let pointer = SCNNode(geometry: SCNSphere(radius: 0.01))
                pointer.name = "pointer"
                pointer.position = currentPosition
                
                self.sceneView.scene.rootNode.enumerateChildNodes { node, _ in
                    if node.name == "pointer" {
                        node.removeFromParentNode()
                    }
                }
                
                self.sceneView.scene.rootNode.addChildNode(pointer)
                pointer.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
            }
        }
    }
    
}

func +(left:SCNVector3, right:SCNVector3) -> SCNVector3 {
    return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
}

