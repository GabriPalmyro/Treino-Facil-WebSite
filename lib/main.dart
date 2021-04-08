// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:io' as io;
import 'dart:js' as js;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:image_whisperer/image_whisperer.dart';

import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Treino Fácil WebSite',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Adicionar exercícios'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  ScrollController _controller;
  ScrollController _controller2;

  double _width;
  bool _isLoading = false;

  //exercicios infos
  final _titleController = TextEditingController();
  final _muscleIdController = TextEditingController();
  final _levelController = TextEditingController();
  // ignore: non_constant_identifier_names
  bool home_exe = false;

  //list of exe
  List _resultList = [];

  //picker
  String downloadUrl;
  File image;
  BlobImage blobImage;
  NetworkImage imageFile;

  @override
  void initState() {
    _controller = ScrollController();
    _controller2 = ScrollController();
    super.initState();
    getMuscleSnapshots();
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller2.dispose();
    super.dispose();
  }

  void _resetFields() {
    setState(() {
      _titleController.text = "";
      _muscleIdController.text = "";
      _levelController.text = "";
      image = null;
      imageFile = null;
      _controller.animateTo(0,
          duration: Duration(seconds: 1), curve: Curves.ease);
      getMuscleSnapshots();
    });
  }

  void _getMuscleGif() {
    InputElement uploadInput = FileUploadInputElement()..accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files.first;
      final reader = FileReader();
      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((event) {
        setState(() {
          image = file;
        });

        BlobImage blobImage = new BlobImage(image, name: image.name);
        imageFile = NetworkImage(blobImage.url);

        print(image.type);
        print("Done and uploading");
      });
    });
  }

  void _createNewExe() async {
    String levelTemp =
        _levelController.text.replaceAll(new RegExp(r'[^0-9]'), '');
    int level = int.parse(levelTemp);

    await fb
        .storage()
        .refFromURL(
            "gs://treino-facil-22856.appspot.com/exercicios/${_muscleIdController.text}")
        .child("${image.name}")
        .put(image)
        .future
        .then((value) async {
      if (value.state == fb.TaskState.SUCCESS) {
        await value.ref.getDownloadURL().then((value) {
          downloadUrl = value.toString();
          var data = {
            "title": _titleController.text,
            "muscleId": _muscleIdController.text,
            "level": level,
            "home_exe": home_exe,
            "video": downloadUrl
          };

          FirebaseFirestore.instance
              .collection("musculos2")
              .add(data)
              .then((value) {
            print("Succesfuly Uploaded");
            showTopSnackBar(
              context,
              CustomSnackBar.success(
                message: "Exercício adicionado com sucesso!",
              ),
            );
            setState(() {
              _width = MediaQuery.of(context).size.width * .2;
              _isLoading = false;
              _resetFields();
            });
          }).catchError((error) {
            print(error);
          });
        });
      }
    }).catchError((error) {
      print(error);
    });
  }

  getMuscleSnapshots() async {
    QuerySnapshot data;

    data = await FirebaseFirestore.instance
        .collection("musculos2")
        .orderBy("title")
        .get();

    setState(() {
      _resultList = data.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    _width =
        // ignore: unrelated_type_equality_checks
        (TargetPlatform == TargetPlatform.android) ||
                // ignore: unrelated_type_equality_checks
                (TargetPlatform == TargetPlatform.iOS)
            ? MediaQuery.of(context).size.width * 0.3
            : MediaQuery.of(context).size.width * 0.6;

    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(fontSize: 24, color: Colors.black),
          ),
          centerTitle: true,
          actions: [
            IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  _resetFields();
                })
          ],
        ),
        backgroundColor: Color(0xff313131),
        body: Scrollbar(
          thickness: 10,
          controller: _controller,
          isAlwaysShown: true,
          child: SingleChildScrollView(
            controller: _controller,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                        horizontal:
                            // ignore: unrelated_type_equality_checks
                            (TargetPlatform == TargetPlatform.android) ||
                                    // ignore: unrelated_type_equality_checks
                                    (TargetPlatform == TargetPlatform.iOS)
                                ? MediaQuery.of(context).size.width * 0.2
                                : MediaQuery.of(context).size.width * 0.3),
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      controller: _titleController,
                      style: TextStyle(color: Colors.amber),
                      showCursor: true,
                      enableInteractiveSelection: true,
                      decoration: InputDecoration(
                        labelText: "Titulo",
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.white, width: 2.0),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.amber, width: 2.0),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2.0),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      // ignore: missing_return
                      validator: (text) {
                        if (text.isEmpty) return "Titulo vazio";
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: _muscleIdController,
                          style: TextStyle(color: Colors.amber),
                          showCursor: true,
                          enableInteractiveSelection: true,
                          decoration: InputDecoration(
                            labelText: "Músculo",
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 2.0),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.amber, width: 2.0),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          // ignore: missing_return
                          validator: (text) {
                            if (text.isEmpty) return "Musculo vazio";
                          },
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: _levelController,
                          style: TextStyle(color: Colors.amber),
                          showCursor: true,
                          enableInteractiveSelection: true,
                          decoration: InputDecoration(
                            labelText: "Level",
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 2.0),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.amber, width: 2.0),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 2.0),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          // ignore: missing_return
                          validator: (text) {
                            if (text.isEmpty) return "Level vazio";
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                    height: 120,
                    child: Column(
                      children: [
                        Text(
                          "Fazer em casa",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontFamily: "GothamLight",
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      home_exe = true;
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.all(10),
                                    width: 130,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: home_exe
                                          ? Colors.amber
                                          : Color(0xff313131),
                                      boxShadow: home_exe
                                          ? [
                                              BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  spreadRadius: 3,
                                                  blurRadius: 2,
                                                  offset: Offset(0, 4))
                                            ]
                                          : [
                                              BoxShadow(
                                                  color: Colors.transparent)
                                            ],
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(30)),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Sim",
                                        style: TextStyle(
                                            color: home_exe
                                                ? Color(0xff313131)
                                                : Colors.amber,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  )),
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      home_exe = false;
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.all(10),
                                    width: 130,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      boxShadow: !home_exe
                                          ? [
                                              BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  spreadRadius: 3,
                                                  blurRadius: 2,
                                                  offset: Offset(0, 4))
                                            ]
                                          : [
                                              BoxShadow(
                                                  color: Colors.transparent)
                                            ],
                                      color: !home_exe
                                          ? Colors.amber
                                          : Color(0xff313131),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(30)),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Não",
                                        style: TextStyle(
                                            color: !home_exe
                                                ? Color(0xff313131)
                                                : Colors.amber,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  TextButton(
                      onPressed: () async {
                        _getMuscleGif();
                      },
                      child: Text(
                        "Selecionar arquivo",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 28, color: Colors.white),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  image != null
                      ? Container(
                          child: Column(
                            children: [
                              Image.network(
                                imageFile.url,
                                height: 100,
                                width: MediaQuery.of(context).size.width * 0.3,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "${image.name}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 28),
                              ),
                            ],
                          ),
                        )
                      : Text(
                          "No data",
                          textAlign: TextAlign.center,
                        ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.4),
                    child: TextButton(
                        onPressed: () {
                          setState(() {
                            image = null;
                            imageFile = null;
                          });
                        },
                        child: Text("Apagar foto")),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  !_isLoading
                      ? AnimatedContainer(
                          duration: Duration(seconds: 2),
                          curve: Curves.ease,
                          margin: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * 0.1,
                          ),
                          height: 50,
                          width: _width,
                          child: InkWell(
                            onTap: () {
                              print("Apertou");
                              if (_formKey.currentState.validate()) {
                                setState(() {
                                  _width = 0;
                                  _isLoading = true;
                                });
                                _createNewExe();
                              }
                            },
                            child: Center(
                              child: Text(
                                "Adicionar exercício",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "GothamBook",
                                    fontSize: 18),
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 3,
                                    blurRadius: 2,
                                    offset: Offset(0, 4))
                              ]),
                        )
                      : Center(child: CircularProgressIndicator()),
                  SizedBox(
                    height: 50,
                  ),
                  Divider(),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.amber, width: 5),
                        borderRadius: BorderRadius.circular(10)),
                    margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.15),
                    height: 400,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Text(_resultList.length.toString() +
                              " exercícios\ncadastrados"),
                        ),
                        Scrollbar(
                          controller: _controller2,
                          showTrackOnHover: true,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(10),
                            itemCount: _resultList.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 100),
                                child: InkWell(
                                  onTap: () {
                                    js.context.callMethod(
                                        'open', [_resultList[index]["video"]]);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 30),
                                    child: Text(
                                      _resultList[index]["title"] +
                                          " - " +
                                          _resultList[index]["muscleId"],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey[900]),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 100,
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
