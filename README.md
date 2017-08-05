*Esse tutorial foi escrito utilizando Xcode 8.3.3 e Swift 3.*

# iOS Custom Camera

### Introdução ###

Nesse tutorial será explicado como customizar uma sessão da câmera utilizando o framework [AVFoundation](https://developer.apple.com/av-foundation/).

## Vamos começar ##

*Projeto incial encontra-se na branch master.*

1. Crie um projeto novo no Xcode e selecione a opção Single View Application.
2. Na Main.storyboard adicione dois UIButton e uma UIView.

>*os botoões futuramente serão utilizados um para captura de imagem e outro para definir a orientação da camera, já a view será utilizada para adicionarmos a sessão da camera que será inicializada.*

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
>Vamos entender para que funciona cada variavel criada:
>1. É responsavel por iniciar uma sessão da camera.
>2. É responsavel por capturar a imagem.
>3. É responsavel por mostrar a previa da captura da imagem.
>4. É o dispositivo encontrado para captura da imagem.
>5. É responsavel por controlar a orientação da camera (traseira ou frontal).

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

>Vamos entender o que essa função faz:
>1. Tenta adicionar um dispositivo na sessão de captura.
>2. Caso possivel adicionar o dispositivo, ele é finalmente adicionado na sessão e também é adicionada a captura de imagem.

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

>Vamos entender essa função:
>1. Responsavel por definir a qualidade da imagem que vai ser capturada. Necessario tomar cuidado com essa linha, pois caso coloque a opção *AVCaptureSessionPreset1920x1080* por exemplo, com a camera frontal ocorre erro.
>2. Responsavel por procurar algum dispositivo de camera.
>3. Responsavel por definir a orientação da camera (traseira ou frontal).

Após criada as funções **beginSession()** e **setDevice()**, precisamos adicionar no arquivo **Info.plist** a permissão de uso da camera, para isso devemos adicionar a **Privacy - Camera Usage Description**, conforme imagem abaixo:

<img width="718" alt="screen shot 2017-08-04 at 20 08 55" src="https://user-images.githubusercontent.com/7603806/28990160-11f1d5d2-7951-11e7-8ad3-d749895186ac.png">

Agora que já adicionamos a permissão de uso da camera, precisamos sobreescrever a função **viewDidLayoutSubviews()**, ela é necessaria para podermos modificar as views adicionas na viewController.

```swift
import UIKit
import AVFoundation

class ViewController: UIViewController {

   ...
   
   override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        captureSession.startRunning()
        previewLayer?.frame = self.previewView.bounds
        
    }
   
   ...
```

Feito todos os passos anteriores, é hora de vermos o resultado. Para isso vale lembrar que o simulador nao dispõe de camera, sendo assim necessario executar a aplicação em seu aparelho.\
Ao executar você deverá ver a imagem da camera e dois botões, porem ainda sem implementação.

![image03](https://user-images.githubusercontent.com/7603806/28991637-e91eca38-7960-11e7-85e5-5aaf000af2f7.jpg)

Vamos começar a persolanizar nossa camera, para isso iremos implementar a action **changeCamera()** e criar uma nova função chamada **endSession()**.

```swift
import UIKit
import AVFoundation

class ViewController: UIViewController {

   ...
   
    @IBAction func changeCamera(_ sender: Any) {
        cameraflag = !cameraflag
        endSession()
        setDevice()
    }
    
    func endSession(){
        captureSession.removeInput(captureSession.inputs[0] as! AVCaptureDeviceInput )
    }
   
   ...
```

>Vamos entender essas funções:
>Começando pela **endSession**, essa implementação remove a sessão de camera existente no momento. Isso é feito para que ao trocarmos a flag da orientação da camera na action **changeCamera()** possamos iniciar uma nova sessão, dessa vez com a orientação inversa da anterior exibida.\

Executando novamente o aplicativo, note que agora o botão **trocar** altera a orientação da camera.
\
*caso não tenha conseguido o resultado esperado, verifique se todos os passos acima foram feitos corretamente!*
\
Aplicação rodando como o esperado, vamos agora adicionar em nossa **ViewController** a interface do delegate **AVCapturePhotoCaptureDelegate** e implementar a funcar **capture()** obrigatoria ao usarmos a interface *AVCapturePhotoCaptureDelegate*, lembrando que essa função não é a mesma da action criada anteriormente!.

```swift
import UIKit
import AVFoundation

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {
 
   ...
   
     func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
        
        //1
        if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            print(UIImage(data: dataImage)?.size ?? "?")           
        }
    }


}
```
>Vamos entender essa função:
>1. Caso não ocorra nenhum erro com a imagem, ele imprime no console o tamanho da imagem capturada.

Vamos finalmente implementar a action **capture()** para que possamos capturar a imagem da camera.

```swift
import UIKit
import AVFoundation

class ViewController: UIViewController, AVCapturePhotoDelegate {
 
   ...
   
   
    @IBAction func capture(_ sender: Any) {
       
        //1
        if let _ = capturePhotoOutput.connection(withMediaType: AVMediaTypeVideo) {
            let settings = AVCapturePhotoSettings()
            let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
            let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                                 kCVPixelBufferWidthKey as String: 160,
                                 kCVPixelBufferHeightKey as String: 160]
            settings.previewPhotoFormat = previewFormat

            //2
            capturePhotoOutput.capturePhoto(with: settings, delegate: self)
        }

        
    }
    
    ...

}
```

>Vamos entender essa função:
>1. Se houver conexão com a saida de imagem, realiza as configurações da imagem.
>2. Captura a imagem com as configurações definidas acima.

*Executando o aplicativo a partir dessa parte, ao clicar no botão **capturar** é impresso no console o tamanho da imagem capturada*

Chegou a hora de finalmente customizar sua sessão da camera, para isso iremos adicionar um overlay sobre a sessão. Para iniciarmos essa parte, é necessario colocar o overlay desejado na pasta **Assets.xcassets**.\
>*caso queira utilizar o mesmo overlay que iremos utilizar no tutorial, a imagem encontra-se na pasta **recursos** nomeada **overlay.png**.* 

Após adicionada a imagem na pasta assets é hora de voltarmos ao codigo para declarar uma variavel de referencia ao overlay e uma referencia de UIImageView, que é onde nosso overlay ficara atribuido.

```swift
import UIKit
import AVFoundation

class ViewController: UIViewController, AVCapturePhotoDelegate {
 
    var imageView: UIImageView?
    var img: UIImage = #imageLiteral(resourceName: "overlay") 
    
    ...

}
```

Vamos agora atualizar nossa função **viewDidLayoutSubviews()** para que adicione nosso overlay na sessão da camera.

```swift
import UIKit
import AVFoundation

class ViewController: UIViewController, AVCapturePhotoDelegate {
 
    ...
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        captureSession.startRunning()
        previewLayer?.frame = self.previewView.bounds
        //1
        imageView = UIImageView(image: img)
        imageView?.contentMode = .scaleToFill
        
        //2
        imageView?.frame = CGRect(x: Double(self.previewView.center.x - self.previewView.frame.width / 4 ), y: Double(self.previewView.center.y - self.previewView.frame.height / 8), width: Double(self.previewView.frame.width / 2 ), height: Double(self.previewView.frame.height / 4))
        
        //3
        self.previewView.addSubview(imageView!)
    }
    
    ...

}
```
>Vamos entender essa função:
>1. Adicionamos a imagem de nosso overlay em uma view.
>2. Configuramos a nossa a posição em que nossa view ficara localizada em cima da sessão, nesse caso é configurado que o eixo x ficará centralizado, o eixo y ficará centralizado também, a largura será metade da largura total da sessão e a altura será de um quarto da altura total da sessão.
>3. Adicionamos o overlay na sessão.

Vamos agora ao momento tão esperado, execute o aplicativo e vejá como ficou o resultado final.

![image04](https://user-images.githubusercontent.com/7603806/28993834-9fae5f18-7996-11e7-931c-dbb839dc42d4.jpg)


Esse tutorial fica por aqui, caso tenha interesse em salvar a imagem customizada, siga o tutorial [Salvando Foto com Overlay](https://github.com/GuilhermeGatto/Salvando-Foto-com-Overlay).

Obrigado!

### Tutorial criado por:
#### Bruno Cruz - [Linkedin](https://www.linkedin.com/in/bruno-cruz-939a0ab8/) | [Github](https://github.com/brunocruzz)
#### Guilherme Gatto - [Linkedin](https://www.linkedin.com/in/guilhermegatto/) | [Github](https://github.com/GuilhermeGatto)


