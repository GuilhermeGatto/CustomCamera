*Esse tutorial foi escrito utilizando Xcode 8.3.3 e Swift 3.*

# iOS Custom Camera

### Introdução ###

Nesse tutorial será explicado como customizar uma sessão da câmera utilizando o framework [AVFoundation](https://developer.apple.com/av-foundation/).

## Vamos começar ##

*Projeto incial encontra-se na branch master.*

1. Crie um projeto novo no Xcode e selecione a opção Single View Application.
2. Na Main.storyboard adicione dois UIButton e uma UIView.

*os botoões futuramente serão utilizados um para captura de imagem e outro para definir a orientação da camera, já a view será utilizada para adicionarmos a sessão da camera que será inicializada.*

![image01](https://user-images.githubusercontent.com/7603806/28988563-c098ad8c-7946-11e7-9fae-28073d7f2fad.png)

Após criada sua view controller, adicione em **ViewController.swift** o outlets da UIView adicionada na Storyboard, no exemplo chamamos de *previewView* e actions para os UIButton que foram adicionados, no exemplo chamamos de capture e changeCamera.

```swift
import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var previewView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    @IBAction func capture(_ sender: Any) {
    }
    
    @IBAction func changeCamera(_ sender: Any) {
    }

}
```

Após realizado esses passos, devemos importar a biblioteca AVfoundation e criar algumas variaveis.

```swift
import UIKit
import AVFoundation

class ViewController: UIViewController {

    //1
    let captureSession = AVCaptureSession()
    //2
    let capturePhotoOutput = AVCapturePhotoOutput()
    //3
    var previewLayer: AVCaptureVideoPreviewLayer?
    //4
    var captureDevice: AVCaptureDevice?
    //5
    var cameraflag = true
    
    ...
```
Vamos entender para que funciona cada variavel criada: 

1. É responsavel por iniciar uma sessão da camera.
2. É responsavel por capturar a imagem.
3. É responsavel por mostrar a previa da captura da imagem.
4. É o dispositivo encontrado para captura da imagem.
5. É responsavel por controlar a orientação da camera (traseira ou frontal).

Agora que entendemos para que funciona cada variavel, vamos criar uma função chamada **beginSession()**.


```swift
import UIKit
import AVFoundation

class ViewController: UIViewController {

   ...
   
   func beginSession() {
        
        do {
            //1
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
            
            //2
            if captureSession.canAddOutput(capturePhotoOutput) {
                captureSession.addOutput(capturePhotoOutput)
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                if let pl = previewLayer {
                    self.previewView.layer.addSublayer(pl)
                }
            }
        }
        catch {
            print("error: \(error.localizedDescription)")
        }
    }
    
   ...
```

Vamos entender o que essa função faz:

1. Tenta adicionar um dispositivo na sessão de captura.
2. Caso possivel adicionar o dispositivo, ele é finalmente adicionado na sessão e também é adicionada a captura de imagem.

Após termos essa função concluida, teremos que criar mais uma chamada **setDevice** e realizar a chamada dela na **viewDidLoad**.

```swift
import UIKit
import AVFoundation

class ViewController: UIViewController {

   ...
   
   override func viewDidLoad() {
        super.viewDidLoad()
        setDevice()

    }
   
   
   func setDevice(){
        
        //1
        self.captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        //2
        guard let devices = AVCaptureDeviceDiscoverySession.init(deviceTypes: [.builtInTelephotoCamera,.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .unspecified).devices else {
            print("Não encontrou a camera")
            return
        }
        
        //3
        for device in devices {
            if self.cameraflag {
                if device.position == AVCaptureDevicePosition.back {
                    captureDevice = device
                    beginSession()
                    break
                }
            }else{
                if device.position == AVCaptureDevicePosition.front {
                    captureDevice = device
                    beginSession()
                    break
                }
            }
        }
    }

    
   ...
```

Vamos entener essa função:

1. Responsavel por definir a qualidade da imagem que vai ser capturada. Necessario tomar cuidado com essa linha, pois caso coloque a opção *AVCaptureSessionPreset1920x1080* por exemplo, com a camera frontal ocorre erro.
2. Responsavel por procurar algum dispositivo de camera.
3. Responsavel por definir a orientação da camera (traseira ou frontal).

Após criada as funções **beginSession()** e **setDevice()**, precisamos adicionar no arquivo **Info.plist** a permissão de uso da camera, para isso devemos adicionar a **Privacy - Camera Usage Description**, conforme imagem abaixo:


