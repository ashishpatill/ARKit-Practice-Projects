//
//  ViewController.swift
//  Solar System
//
//  Created by Ashish Pisey on 07/05/22.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.session.run(configuration)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let sunPosition = SCNVector3(0, 0, -0.5)
        let sun = addPlanet(radius: 0.35, diffuse: "Sun", position: sunPosition)
        self.sceneView.scene.rootNode.addChildNode(sun)
        
        let earthPosition = SCNVector3(1.2, 0, 0)
        let earth = addPlanet(radius: 0.1, diffuse: "EarthDay", specular: "EarthSpecular", emission: "EarthClouds", normal: "EarthNormal", position: earthPosition)
        sun.addChildNode(earth)
        
        let venusPosition = SCNVector3(0.7, 0, 0)
        let venus = addPlanet(radius: 0.08, diffuse: "VenusDiffuse", emission: "VenusEmission", position: venusPosition)
        sun.addChildNode(venus)
        
        let earthParent = SCNNode()
        let venusParent = SCNNode()
        let moonParent = SCNNode()

        moonParent.position = earthPosition
        earthParent.position = sunPosition
        venusParent.position = sunPosition
        
        self.sceneView.scene.rootNode.addChildNode(sun)
        self.sceneView.scene.rootNode.addChildNode(earthParent)
        self.sceneView.scene.rootNode.addChildNode(venusParent)

        
        let moon = addPlanet(radius: 0.05, diffuse: "Moon", position: SCNVector3(0,0,-0.2))

        let sunAction = Rotation(time: 8)
        let earthParentRotation = Rotation(time: 14)
        let venusParentRotation = Rotation(time: 10)
        let earthRotation = Rotation(time: 8)
        let moonRotation = Rotation(time: 5)
        let venusRotation = Rotation(time: 8)
        
        
        earth.runAction(earthRotation)
        venus.runAction(venusRotation)
        earthParent.runAction(earthParentRotation)
        venusParent.runAction(venusParentRotation)
        moonParent.runAction(moonRotation)

        
        sun.runAction(sunAction)
        earthParent.addChildNode(earth)
        earthParent.addChildNode(moonParent)
        venusParent.addChildNode(venus)
        earth.addChildNode(moon)
        moonParent.addChildNode(moon)
    }
    
    func addPlanet( radius: CGFloat, diffuse: String, specular: String? = nil, emission: String? = nil, normal: String? = nil, position: SCNVector3) -> SCNNode {
        let node = SCNNode(geometry: SCNSphere(radius: radius))
        node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: diffuse)
        
        if let specular = specular {
            node.geometry?.firstMaterial?.specular.contents = UIImage(named: specular)
        }
        
        if let emission = emission {
            node.geometry?.firstMaterial?.emission.contents = UIImage(named: emission)
        }
        
        if let normal = normal {
            node.geometry?.firstMaterial?.normal.contents = UIImage(named: normal)
        }
        
        node.position = position
        
        return node
    }
    
    func Rotation(time: TimeInterval) -> SCNAction {
        let Rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreeToRadians), z: 0, duration: time)
        let foreverRotation = SCNAction.repeatForever(Rotation)
        return foreverRotation
    }


}
                            
extension Int {
    var degreeToRadians: Double { return Double(self) * .pi/180 }
}
                            
                            

