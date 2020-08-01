import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ticket_scanner/main.dart';
import 'package:ticket_scanner/ticket.dart';

class OcrPage extends StatefulWidget {
  final Function() notifyParent;

  const OcrPage({Key key, this.notifyParent}) : super(key: key);

  @override
  createState() => _OcrPageState();
}

class _OcrPageState extends State<OcrPage> {
  CameraImage _cameraImage;
  bool _cameraInitialised = false;
  bool capturing = false;
  CameraController cameraController;
  bool hasTip = false;
  double lastTotal = 0;

  void _captureTicket() {
    cameraController.startImageStream((CameraImage image) {
      cameraController.stopImageStream();
      _processTicket(image);
    });
    capturing = false;
  }

  void addTicket(Ticket ticket) {
    Properties.getTickets().add(ticket);
    setState(() {
      Properties.setStatusColor(Colors.green);
    });
    widget.notifyParent();
  }

  void _processTicket(CameraImage _cameraImage) async {
    if (!capturing) {
      Ticket ticket = new Ticket();
      hasTip = false;
      capturing = true;
      final FirebaseVisionImageMetadata metadata = FirebaseVisionImageMetadata(
          rawFormat: _cameraImage.format.raw,
          size: Size(
              _cameraImage.width.toDouble(), _cameraImage.height.toDouble()),
          planeData: _cameraImage.planes
              .map((currentPlane) =>
              FirebaseVisionImagePlaneMetadata(
                  bytesPerRow: currentPlane.bytesPerRow,
                  height: currentPlane.height,
                  width: currentPlane.width))
              .toList(),
          rotation: ImageRotation.rotation90);

      final image =
      FirebaseVisionImage.fromBytes(_cameraImage.planes[0].bytes, metadata);
      final textReader = FirebaseVision.instance.textRecognizer();
      final VisionText visionText = await textReader.processImage(image);
      for (TextBlock block in visionText.blocks) {
        for (TextLine line in block.lines) {
          print(line.text);
          populateTicketInfo(ticket, line.text);
        }
      }
      if (ticket.isValid() && ticket.getTotal() != lastTotal) {
        lastTotal = ticket.getTotal();
        print("last total = " + lastTotal.toString());
        addTicket(ticket);
        return;
      } else if (hasTip && ticket.getTotal() != lastTotal) {
        print("last total = " + lastTotal.toString());

        print("t total = " + ticket.getTotal().toString());
        await _showTipsDialog(
            ticket,
            (ticket.getTotal() -
                ticket.getSubTotal() -
                ticket.getDeliveryFee()));
        if (ticket.isValid()) {
          lastTotal = ticket.getTotal();
          addTicket(ticket);
          return;
        }
      }
      setState(() {
        Properties.setStatusColor(Colors.red);
      });
      lastTotal = 0;
    }
  }

  void populateTicketInfo(Ticket ticket, String line) {
    List<String> keys = [
      "sub",
      "very",
      "customer:",
      "tel",
      "address",
      "total:",
      "paid",
      "pick",
      "tip",
      "vat"
    ];
    List<String> values = [
      "subtotal",
      "delivery",
      "name",
      "tel",
      "address",
      "total",
      "paid",
      "pick",
      "tip",
      "vat"
    ];

    String match = "default";

    int index;

    for (int i = 0; i < keys.length; i++) {
      if (line.toLowerCase().contains(keys[i])) {
        match = values[i];
        print(values[i]);
        index = i;
        break;
      }
    }

    try {
      switch (match) {
        case "subtotal":
          ticket.setSubTotal(double.parse(
              line.replaceAll(new RegExp("[^\\.0123456789]"), "")));
          break;
        case "vat":
          ticket.setVAT(double.parse(
              line.replaceAll(new RegExp("[^\\.0123456789]"), "")));
          break;
        case "tip":
          setState(() {
            hasTip = true;
          });
          break;
        case "pick":
          ticket.setDelivery(false);
          break;
        case "delivery":
          if (!line.contains("fe")) {
            ticket.setDelivery(true);
          } else {
            ticket.setDeliveryFee(double.parse(
                line.replaceAll(new RegExp("[^\\.0123456789]"), "")));
          }
          break;
        case "name":
          ticket.setName(line.split(":")[1]);
          break;
        case "tel":
          ticket.setTel(line.split(":")[1]);
          break;
        case "address":
          ticket.setAddress(line.split(":")[1]);
          break;
        case "total":
          if (line.toLowerCase().startsWith("total:")) {
            ticket.setTotal(double.parse(
                line.replaceAll(new RegExp("[^\\.0123456789]"), "")));
          }
          break;
        case "paid":
          if (line.toLowerCase().contains("un")) {
            ticket.setPaid(false);
          } else {
            ticket.setPaid(true);
          }
          break;
        default:
      }
    } catch (RangeError) {
      print("ERROR IN LINE: " + line);
    }
  }

  Future<void> _showTipsDialog(Ticket ticket, double tips) async {
    TextEditingController _tipController = new TextEditingController();
    _tipController.text = tips.toStringAsFixed(2);
    return (showDialog(
        context: context,
        barrierDismissible: false,
        child: new AlertDialog(
          content: Text("Tips = £" + tips.toStringAsFixed(2) + "?", style: TextStyle(fontSize: 20)),
          actions: <Widget>[
            FlatButton(
                child: Text("No"),
                onPressed: () {
                  Navigator.pop(context);
                }),
            FlatButton(
                child: Text("Yes"),
                onPressed: () {
                  Navigator.pop(context);
                  print(double.parse(_tipController.text));
                  ticket.setTips(double.parse(_tipController.text));
                  widget.notifyParent();
                })
          ],
        )));
  }

  @override
  void initState() {
    super.initState();
    cameraController =
        CameraController(Properties.getCameras()[0], ResolutionPreset.max);
    cameraController.initialize().then((_) async {
      setState(() {
        _cameraInitialised = true;
      });
    });
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!cameraController.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(title: Text("Press + to scan!")),
      backgroundColor: Properties.getStatusColor(),
      body: Column(
        children: <Widget>[
          Center(
              child: (_cameraInitialised)
                  ? AspectRatio(
                aspectRatio: cameraController.value.aspectRatio,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      Properties.setStatusColor(Colors.amber);
                    });
                    _captureTicket();
                  },
                  child: CameraPreview(cameraController),
                ),
              )
                  : CircularProgressIndicator()),
        ],
      ),
    );
  }
}
