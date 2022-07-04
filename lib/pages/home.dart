import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [];

  @override
  void initState() {
    super.initState();
    final socket = Provider.of<SocketService>(context, listen: false);

    socket.socket.on('active-bands', _handleActivceBands);
  }

  _handleActivceBands( dynamic payload) {
    setState(() {
      bands = (payload as List).map((e) => Band.fromMap(e as Map<String, dynamic>)).toList();
    });
  }

  @override
  void dispose() {
    final socket = Provider.of<SocketService>(context, listen: false);
    socket.socket.off('active-bands');
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    final socket = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BandNames', style: TextStyle(color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: (socket.serverStatus == ServerStatus.Online )
            ?  Icon(Icons.check_circle, color: Colors.blue[300])
            : const Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
      ),
      body: Column(
        children: [

          _showGraph(),

          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, index) => bandTile(bands[index])
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        elevation: 1,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget bandTile(Band band) {

    final socetService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => socetService.emit('delete-band', {'id': band.id}),
      background: Container(
        padding: const EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete Band', style: TextStyle(color: Colors.white))
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0,2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: const TextStyle(fontSize: 20)),
        onTap: () {
          socetService.socket.emit('vote-band', {'id': band.id});
          setState(() {});
        },
      ),
    );
  }

  addNewBand() {

    final TextEditingController textEditingController = TextEditingController();

    if(Platform.isAndroid) {

      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('New and name:'),
            content: TextField(
              controller: textEditingController,
            ),
            actions: [
              MaterialButton(
                child: const Text('Add'),
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () => addBandToList(textEditingController.text.trim())
              )
            ],
          );
        }
      );

    }

    showCupertinoDialog(
      context: context,
      builder: (_) {
        return CupertinoAlertDialog(
          title: const Text('New band name:'),
          content: CupertinoTextField(
            controller: textEditingController,
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Add'),
              onPressed: () => addBandToList(textEditingController.text.trim()),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Dismiss'),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      }
    );

  }

  void addBandToList(String name) {
    print(name);
    if(name.length > 1) {
      //se puede agregar
      // bands.add(Band(id: DateTime.now().toString(), name: name, votes: 0));
      final socket = Provider.of<SocketService>(context, listen: false) ;
      socket.emit('add-band', {'name': name});
    }


    Navigator.pop(context);

  }

  Widget _showGraph() {

    Map<String, double> dataMap = {
      // "Flutter": 5,
    };

    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    return PieChart(
      dataMap: dataMap,
      animationDuration: const Duration(milliseconds: 800),
      chartLegendSpacing: 32,
      chartRadius: MediaQuery.of(context).size.width / 3.2,
      chartType: ChartType.ring,
      ringStrokeWidth: 12,
      legendOptions: const LegendOptions(
        legendPosition: LegendPosition.right,
      ),
      chartValuesOptions: const ChartValuesOptions(
        decimalPlaces: 0,
      ),
    );
  }


}