//import 'dart:html';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/ble/ble_device_connector.dart';
import 'package:provider/provider.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'src/ble/ble_device_interactor.dart';
import 'src/ble/ble_scanner.dart';
import 'src/ui/device_list.dart';
import 'src/ble/ble_logger.dart';
import 'src/ui/ble_status_screen.dart';
import 'src/ble/ble_status_monitor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final ble = FlutterReactiveBle();
  final bleLogger = BleLogger(ble: ble);
  final monitor = BleStatusMonitor( ble);
  final scanner = BleScanner(ble: ble, logMessage: bleLogger.addToLog);
  final connector = BleDeviceConnector(
    ble: ble,
    logMessage: bleLogger.addToLog,
  );
  final serviceDiscoverer = BleDeviceInteractor(
    bleDiscoverServices: (deviceId) async {
      await ble.discoverAllServices(deviceId);
      return ble.getDiscoveredServices(deviceId);
    },
    logMessage: bleLogger.addToLog,
    readRssi: ble.readRssi,
  );
  
  



  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: scanner),
        Provider.value(value: bleLogger),
        Provider.value(value: monitor),
        Provider.value(value: connector),
        Provider.value(value: serviceDiscoverer),
        StreamProvider<BleStatus?>(
          create: (_) => monitor.state,
          initialData: BleStatus.unknown,
        ),
         StreamProvider<BleScannerState?>(
          create: (_) => scanner.state,
          initialData: const BleScannerState(
            discoveredDevices: [],
            scanIsInProgress: false,
          ),
        ),
        StreamProvider<ConnectionStateUpdate>(
          create: (_) => connector.state,
          initialData: const ConnectionStateUpdate(
            deviceId: 'Unknown device',
            connectionState: DeviceConnectionState.disconnected,
            failure: null,
          ),
        ),
      ],
      child: MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 34, 255, 52)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

   void getNext() {
    current = WordPair.random();
    
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }


}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoriteList();
      case 2:
        page = BTStatusIndicator();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context,constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.bluetooth),
                      label: Text('Bluetooth'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                      setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

List<Widget> produceWidgetList (List<WordPair> source)
{
  List<Widget> toRet = [for(var item in source)BigCard(pair: item)];
/*
  for( var item in source)
  {
    toRet.add(BigCard(pair:item));
  }  */
  return toRet;  
}
class FavoriteList extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var Wordlist = appState.favorites;

    return Center(
      child:ListView(
        children: produceWidgetList(Wordlist),        
      )
    );

 
  }
  
}



class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(color: theme.colorScheme.onPrimary,);
    return Card(
      color: theme.colorScheme.primary,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(pair.asLowerCase,style: style,textAlign: TextAlign.center,),
      ),
    );
  }
}

class BTStatusIndicator extends StatelessWidget{
  @override
  Widget build(BuildContext context) => Consumer<BleStatus?>(
    builder: (_, status, __) {
          if (status == BleStatus.ready) {
            return const DeviceListScreen();
          } else {
            return BleStatusScreen(status: status ?? BleStatus.unknown);
          }
        },    
  );
  
} 
/*
class BTStatusIndicator extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _BTStatusIndicatorState(); 
}

class _BTStatusIndicatorState extends State<BTStatusIndicator>{
  Future<List<String>> listContent =  getBTconnectListNames();
  

  @override
   Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: listContent,
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        Widget kids;
        if (snapshot.hasData) {
          kids = ListView(
            children: [for(var item in snapshot.data!)BTDEvListItem(text:item)],
          );          
        }
        else
        {
          kids = const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              );
        }
        return kids;
       },
      
    );
   }
}

Future<List<String> > getBTconnectListNames() async {
  List<BluetoothDevice> devs = await FlutterBluePlus.systemDevices;
  for (var d in devs) {
    await d.connect(); // Must connect *our* app to the device
    await d.discoverServices();
}
  List<String> toRet = [for(var item in devs)item.advName];
  //List<Widget> toRet = [for(var item in devs)BTDEvListItem(text:item.advName)];
  return toRet;
}

class BTDEvListItem extends StatelessWidget{
  BTDEvListItem({
    required this.text,
  }
  );
  final String text;

  @override
  Widget build(BuildContext context) {

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(text),
      )
    );
  }
  
}
*/
