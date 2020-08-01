import 'package:flutter/material.dart';
import 'package:ticket_scanner/main.dart';

TextStyle white20style = TextStyle(fontSize: 20, color: Colors.white);
TextStyle grey20style = TextStyle(fontSize: 20, color: Colors.grey[90]);

class Ticket {
  bool _hasPaid;
  bool _isDelivery;
  double _subTotal;
  double _deliveryFee;
  double _vat;
  double _total;
  String _address;
  String _name;
  String _tel;
  double _tips;


  Ticket(){
    _tips = 0;
    _total = 0;
    _subTotal = 0;
    _deliveryFee = 0;
    _vat = 0;
  }

  bool checkSum(){
    return ((_subTotal + _deliveryFee + _tips) == _total);
  }

  bool isValid(){
    if(_hasPaid != null && _isDelivery != null && _total > 0 && checkSum()){
      return true;
    }
    print(_hasPaid);
    print(_isDelivery);
    print(_subTotal);
    print(_deliveryFee);
    print(_total);
    print(checkSum());
    return false;
  }

  void setTips(double tips){
    this._tips = tips;
  }

  double getTips(){
    return this._tips;
  }

  void setSubTotal(double subTotal){
    this._subTotal = subTotal;
  }

  double getSubTotal(){
    return this._subTotal;
  }

  void setDeliveryFee(double fee){
    this._deliveryFee = fee;
  }

  double getDeliveryFee(){
    return this._deliveryFee;
  }

  void setVAT(double vat){
    this._vat = vat;
  }

  double getVAT(){
    return this._vat;
  }

  void setAddress(String address){
    this._address = address;
  }

  String getAddress(){
    return this._address ?? "No Address";
  }

  String getShortAddress(){
    int maxLength = 21;
    String out = this._address ?? "No Address";
    if(out.length > maxLength)
      out = out.substring(0, maxLength);
      out=out+"...";
    return out;
  }

  void setName(String name){
    this._name = name;
  }

  String getName(){
    return this._name ?? "No Name";
  }

  void setTel(String tel){
    this._tel = tel;
  }

  String getTel(){
    return this._tel ?? "N/A";
  }

  void setTotal(double total){
    this._total = total;
  }

  double getTotal(){
    return this._total;
  }

  double getTotalMinusTips(){
    return this._total - this._tips;
  }

  void setDelivery(bool isDelivery){
    this._isDelivery = isDelivery;
  }

  bool getDelivery(){
    return _isDelivery ?? false;
  }

  String getDeliveryText(){
    if(_isDelivery) {
      return "DELIVERY";
    }
    return "COLLECTION";
  }

  void setPaid(bool hasPaid){
    this._hasPaid = hasPaid;
  }

  bool hasPaid(){
    return this._hasPaid;
  }

  String getPaidString(){
    if(_hasPaid){
      return "PAID";
    }
    return "UNPAID";
  }
}


class TicketPage extends StatefulWidget {
  final Function() notifyParent;

  const TicketPage({Key key, this.notifyParent}) : super(key: key);

  @override
  TicketPageState createState() => TicketPageState();
}

class TicketPageState extends State<TicketPage> {
  void refresh() {
    widget.notifyParent();
    setState(() {});
  }

  Future<void> _showClearTicketsDialog() {
    showDialog(
        context: context,
        child: new AlertDialog(
          content: Text("Are you sure you want to clear tickets?"),
          actions: <Widget>[
            FlatButton(
              child: Text("No"),
              onPressed: () => Navigator.pop(context),
            ),
            FlatButton(
                child: Text("Yes"),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    Properties.clearTickets();
                  });
                  refresh();
                }
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Tickets"), actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            onPressed: () {
              _showClearTicketsDialog();
            },
            child: Text("Clear Tickets"),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          )
        ]),
        body: ListView.separated(
          padding: EdgeInsets.all(10),
          itemCount: Properties.getTickets().length,
          itemBuilder: (BuildContext context, int index) {
            Color col = Colors.red;
            if (Properties.getTickets()[index].hasPaid()) {
              col = Colors.green;
            }
            return Material(
              color: col,
              child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TicketInfoPage(
                              notifyParent: refresh, ticketIndex: index)),
                    );
                  },
                  child: Container(
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: new Row(
                        children: <Widget>[
                          Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: new Text(
                                    (index + 1).toString() +
                                        " - " +
                                        Properties.getTickets()[index].getShortAddress(),
                                    style: white20style),
                              ),
                              flex: 65),
                          Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: new Text(
                                    Properties.getTickets()[index]
                                        .getTotal()
                                        .toStringAsFixed(2),
                                    textAlign: TextAlign.right,
                                    style: white20style),
                              ),
                              flex: 35),
                        ],
                      ),
                    ),
                  )),
            );
          },
          separatorBuilder: (BuildContext context, int index) => const Divider(
            height: 7,
          ),
        ));
  }
}

class TicketInfoPage extends StatefulWidget {
  final Function() notifyParent;
  final int ticketIndex;

  const TicketInfoPage({Key key, this.notifyParent, this.ticketIndex})
      : super(key: key);

//  const _TicketInfoPage ({Key key, this._ticketIndex}):super(key:key);

  @override
  TicketInfoPageState createState() => TicketInfoPageState();
}

class TicketInfoPageState extends State<TicketInfoPage> {
  void refresh() {
    widget.notifyParent();
    setState(() {});
  }

  Future<void> _showDeleteTicketsDialog() {
    showDialog(
        context: context,
        child: new AlertDialog(
          content: Text("Are you sure you want to delete this ticket?"),
          actions: <Widget>[
            FlatButton(
              child: Text("No"),
              onPressed: () => Navigator.pop(context),
            ),
            FlatButton(
              child: Text("Yes"),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Properties.removeTicket(widget.ticketIndex);
                widget.notifyParent();
              },
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    Color col = Colors.red;
    if (Properties.getTickets()[widget.ticketIndex].hasPaid()) {
      col = Colors.green;
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(Properties.getTickets()[widget.ticketIndex].getAddress()),
        ),
        body: ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              color: Colors.grey,
              child: new Text(
                  "Name: " +
                      Properties.getTickets()[widget.ticketIndex].getName() +
                      "\n" +
                      "Tel: " +
                      Properties.getTickets()[widget.ticketIndex].getTel() +
                      "\n" +
                      "Address: " +
                      Properties.getTickets()[widget.ticketIndex].getAddress(),
                  style: white20style),
            ),
            Container(height: 10),
            Container(
              padding: EdgeInsets.all(10),
              color: col,
              child: new Text(
                  Properties.getTickets()[widget.ticketIndex].getPaidString() +
                      " - " +
                      Properties.getTickets()[widget.ticketIndex].getDeliveryText(),
                  style: white20style),
            ),
            Container(height: 10),
            Container(
              padding: EdgeInsets.all(10),
              color: Colors.black54,
              child: new Row(
                children: <Widget>[
                  Expanded(
                      child: new Text("Total:" + "\nTips:" + "\nGrand Total:",
                          style: white20style),
                      flex: 80),
                  Expanded(
                      child: new Text(
                          Properties.getTickets()[widget.ticketIndex]
                              .getTotalMinusTips()
                              .toStringAsFixed(2) +
                              "\n" +
                              Properties.getTickets()[widget.ticketIndex]
                                  .getTips()
                                  .toStringAsFixed(2) +
                              "\n" +
                              Properties.getTickets()[widget.ticketIndex]
                                  .getTotal()
                                  .toStringAsFixed(2),
                          style: white20style),
                      flex: 20),
                ],
              ),
            ),
            RaisedButton(
                child: new Text("Delete Ticket", style: grey20style),
                onPressed: () => _showDeleteTicketsDialog())
          ],
          padding: EdgeInsets.all(10),
        ));
  }
}