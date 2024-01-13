import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Image Prediction',
      theme: ThemeData(),
      home: const Camera(),
    );
  }
}

class Camera extends StatefulWidget {
  const Camera({Key? key}) : super(key: key);

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Camera> {
  File? _file;
  String? prediction = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Image Prediction'),
      ),
      body: SingleChildScrollView(
        controller: ScrollController(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                children: <Widget>[
                  _file == null
                      ? const Text("Image not found")
                      : Image.file(_file!),
                  const SizedBox(height: 16),
                  Text(prediction ?? ""), // Menampilkan hasil prediksi di sini
                  const SizedBox(height: 16),
                  _buildButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: <Widget>[
        ElevatedButton(
          onPressed: () => uploadImage(),
          child: const Text("Upload"),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            // await predict(); // Panggil fungsi predict
            // Setelah prediksi selesai, Anda dapat mengakses nilai 'prediction' di sini
            // print("Prediction Result: $prediction");
            
            
            print("test");
            sendJsonToFlask();

            uploadFileImage();
            
           
          },
          child: const Text("Predict"), // Tombol "Predict"
        ),
      ],
    );
  }

  Future<void> uploadFileImage() async {
      File imageFileUpload = File(_file!.path);
      String? fileName = _file?.path
          .split('/')
          .last;

      String uploadEndpoint = "https://aec0-112-78-177-1.ngrok-free.app//uploadFileAndroid"; // Ganti dengan alamat server Flask yang sesuai
      Dio dio = Dio();

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(_file!.path, filename: fileName),
      });

      try {
        Response response = await dio.post(uploadEndpoint, data: formData);
        if (response.data == 'sukses') {
          print('Upload berhasil: ${response.data}');
        } else {
          print('${response.data}');
        }
      } catch (e) {
        print('Error during upload: $e');
      }
    }

  Future<void> uploadImage() async {
    final myfile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (myfile == null) return;

    setState(() {
      _file = File(myfile.path);
      prediction = ""; // Reset hasil prediksi saat mengunggah gambar baru
    });
  }
  Future<void> sendJsonToFlask() async {
      String? Stress;
      if (_file == null) {
        print('File gambar belum dipilih.');
        return;
      }

      String? fileName = _file?.path.split('/').last;
      if (fileName == null) {
        print('Gagal mendapatkan nama file.');
        return;
      }

      String apiUrl = "https://aec0-112-78-177-1.ngrok-free.app//receive_json";
      Dio dio = Dio();

      try {
        final Map<String, String> data = {
          
          'message': fileName,
        };

        // Menggunakan opsi `data` untuk mengirim data dalam format JSON
        final response = await dio.post(
          apiUrl,
          options: Options(
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
            },
          ),
          data: jsonEncode(data),
        );

        // Periksa apakah respons server sukses
        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = response.data; // Use `response.data` for Dio
          String message = responseData['message'];
          String mes1 = responseData['nama'];
          String mes2 = responseData['akurasi'];


          _showAlertDialog(context, 'Hasil Deteksi', 'Sampah $mes1 \nAkurasi $mes2');

          // if (message == 4) {
          //   Stress = "Stress Tingkat Rendah";
          // } else if (message == 5 || message == 1) {
          //   Stress = "Stress Tingkat Sedang";
          // } else if (message == 2 || message == 0) {
          //   Stress = "2";
          // } else {
          //   Stress = "Tidak Ada Stress";
          // }
          // _showAlertDialog(context, 'Tingkat Stress', 'Stress yang Anda alami tingkat $message');
          print("$message $mes1 $mes2");
        } else {
          print('Permintaan gagal. Kode respons: ${response.statusCode}');
        }
      } catch (e) {
        print('Error during request: $e');
      }
    }

    void _showAlertDialog(BuildContext context, String title, String content) {
      // Membuat AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              // Tutup alert
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );

      // Menampilkan AlertDialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }


  Future<void> predict() async {
    if (_file == null) return;

    var uri = Uri.parse("https://aec0-112-78-177-1.ngrok-free.app//receive_json"); // URL endpoint Flask

    var request = http.MultipartRequest("POST", uri);
    var multipartFile = http.MultipartFile(
      'file',
      http.ByteStream(Stream.castFrom(_file!.openRead())),
      _file!.lengthSync(),
      filename: _file!.path.split("/").last,
      contentType: MediaType('image', 'jpeg'),
    );

    request.files.add(multipartFile);

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        setState(() {
          prediction = responseBody; // Menyimpan hasil prediksi
        });
      } else {
        print("Image upload failed.");
      }
    } catch (e) {
      print("Error uploading image: $e");
    }
  }
}