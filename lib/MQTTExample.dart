import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';


class MQTTExample extends StatefulWidget
{
  MQTTExampleState createState()=> MQTTExampleState();
}

class MQTTExampleState extends State<MQTTExample>{

  String LOGTAG="MQTTExample";

  final textController = TextEditingController();

  String _publishedMsg="Welcome to Thingsup!!!";

  final String serverUri = "mqtt.thingsup.io";
  final int port=1883;
  String clientId = "<Your MQTT Client ID>";
  final String MqttTopic = "<Your MQTT Topic>";
  final String Username = "<Your MQTT Username>";
  final String Password = "<Your MQTT Password>";

  MqttClient client;

  @override
  void initState(){

    connectMQTT();

  }

  /*
        Creates MQTT Client and Connected with provided MQTT credentials.
  */
  Future<void> connectMQTT()
  async {

    /*
            In case of Dynamic Client ID
            clientId = clientId+new DateTime.now().millisecondsSinceEpoch.toString();
    */


    if(client==null)
    {
      client=MqttClient(serverUri,clientId);
    }

    client.onConnected=onConnected;
    client.onDisconnected=onDisconnected;
    client.port=port;
    client.logging(on: true);
    client.secure=true;

    try
    {
      await client.connect(Username,Password);
    }
    on Exception catch(e){
      print(LOGTAG+" exception->$e");
    }


    /*
        To listen to subscribed topics
   */
    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload;
      final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);
      UpdateUI("Message Arrived : "+c[0].topic.toString()+" -> "+payload.toString());
      print(LOGTAG+'Received message:$payload from topic: ${c[0].topic}>');
    });

  }

  /*
        To publish a string
  */
  void publishString(String data)
  {
    /*
         Checks if MQTT is connected and TextInput contains non empty String
    */
    if(client.connectionStatus.state==MqttConnectionState.connected && data.isNotEmpty)
    {
      final MqttClientPayloadBuilder builder=MqttClientPayloadBuilder();
      builder.addString(data);
      client.publishMessage(MqttTopic, MqttQos.atLeastOnce, builder.payload);
      client.published.listen((MqttPublishMessage message) {
        print(LOGTAG+" string publilshed on topic->"+message.variableHeader.topicName.toString()+" with Qos->"+message.header.qos.toString());
      });
    }
  }

  /*
        MQTT Connection callbacks
  */
  void onConnected()
  {
    print(LOGTAG+" MQTT is connected");
    client.subscribe(MqttTopic, MqttQos.atLeastOnce);
  }

  void onDisconnected()
  {
    print(LOGTAG+" MQTT is disconnected");
  }


  /*
        To Update UI from Non UI Thread
  */
  void UpdateUI(String data)
  {

    setState(() {
      _publishedMsg=_publishedMsg+"\n\$:"+data;
    });

  }

  @override
  Widget build(BuildContext context) {

    final textField=  TextField(
      obscureText: false,
      controller: textController,
      decoration: InputDecoration(
        hintText: "write text here",
      ),
    );

    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(title: Text("MQTT Example"),),
      body: new Column(
        children: <Widget>[


          Flexible(
            flex: 5,
            fit: FlexFit.tight,
            child:  new Container(
              margin:EdgeInsets.fromLTRB(10, 10, 10, 10),
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              width: MediaQuery.of(context).size.width,
              color: Colors.black,
              child:  new Expanded(
                //flex: 1,
                child: new SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: new Text(_publishedMsg,
                    style: new TextStyle(
                      fontSize: 16.0, color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: new Container(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: <Widget>[
                  Flexible(
                    flex: 3,
                    child: textField,
                  ),
                  Flexible(
                    flex: 1,
                    child:  new RaisedButton(
                      onPressed: () {
                        publishString(textController.text);
                      },
                      child: const Text('Send', style: TextStyle(fontSize: 17,color: Colors.blue,fontWeight: FontWeight.normal),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),

    );
  }
}