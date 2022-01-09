import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;
import 'package:flutter_link_previewer/flutter_link_previewer.dart';

import 'package:qr_scann/database/sites_database.dart';
import 'package:qr_scann/models/site_model.dart';
import 'package:qr_scann/pages/site_page.dart';

class SitesPage extends StatefulWidget {
  const SitesPage({Key? key}) : super(key: key);

  @override
  _SitesPageState createState() => _SitesPageState();
}

class _SitesPageState extends State<SitesPage> {
  ScanResult? scanResult;
  Map<String, PreviewData> datas = {};

  final _flashOnController = TextEditingController(text: 'Flash on');
  final _flashOffController = TextEditingController(text: 'Flash off');
  final _cancelController = TextEditingController(text: 'Cancel');

  final _aspectTolerance = 0.00;
  final _selectedCamera = -1;
  final _useAutoFocus = true;
  final _autoEnableFlash = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sites List'),
      ),
      body: FutureBuilder<List>(
        future: SitesDatabase.instance.readAllSites(),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(10.0),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) {
                    return _buildItem(snapshot.data![i]);
                  },
                )
              : const Center(child: Text('No tienes datos guardados'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scan,
        tooltip: 'Scan QR',
        child: const Icon(Icons.qr_code),
      ),
    );
  }

  Widget _buildItem(Site site) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) async => await SitesDatabase.instance.delete(site.id),
      background: Container(
        padding: const EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Eliminar', style: TextStyle(color: Colors.white)),
        ),
      ),
      child: _sitePreview(site),
    );
  }

  Widget _sitePreview(Site site) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => SitePage(
            webSite: site.url,
            title: datas[site.url]!.title.toString(),
          ),
        ));
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          key: ValueKey(site.id),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
            color: Colors.grey[100],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
            child: AbsorbPointer(
              child: LinkPreview(
                enableAnimation: true,
                onPreviewDataFetched: (data) {
                  setState(() {
                    datas = {
                      ...datas,
                      site.url: data,
                    };
                  });
                },
                previewData: datas[site.url],
                text: site.url,
                width: double.infinity,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _save(url) async {
    final site = Site(url: url, createdTime: DateTime.now());
    await SitesDatabase.instance.create(site);
  }

  Future<void> _scan() async {
    try {
      final result = await BarcodeScanner.scan(
        options: ScanOptions(
          strings: {
            'cancel': _cancelController.text,
            'flash_on': _flashOnController.text,
            'flash_off': _flashOffController.text,
          },
          useCamera: _selectedCamera,
          autoEnableFlash: _autoEnableFlash,
          android: AndroidOptions(
            aspectTolerance: _aspectTolerance,
            useAutoFocus: _useAutoFocus,
          ),
        ),
      );

      if (result.rawContent.isNotEmpty) {
        setState(() => scanResult = result);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SitePage(webSite: scanResult!.rawContent),
          ),
        );
        _save(scanResult!.rawContent);
      }
    } on PlatformException catch (e) {
      setState(
        () {
          scanResult = ScanResult(
            type: ResultType.Error,
            format: BarcodeFormat.unknown,
            rawContent: e.code == BarcodeScanner.cameraAccessDenied
                ? 'The user did not grant the camera permission!'
                : 'Unknown error: $e',
          );
        },
      );
    }
  }
}
