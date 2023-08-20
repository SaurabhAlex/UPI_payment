import 'package:flutter/material.dart';
import 'package:upi_india/upi_india.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<UpiResponse>? _transaction;
  final UpiIndia _upiIndia = UpiIndia();
  List<UpiApp>? apps;

  TextStyle header = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold
  );

  TextStyle value = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold
  );

  @override
  void initState() {
    _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value) {
      setState(() {
        apps = value;
      });
    }).catchError((e){
      print(e);
      apps = [];
    });
    super.initState();
  }

  Future<UpiResponse> initiateTransaction(UpiApp app) async {
    return _upiIndia.startTransaction(
      app: app,
      receiverUpiId: "7982307006@kotak",
      receiverName: 'Mr.Saurabh',
      transactionRefId: 'TestingUpiIndiaPlugin',
      transactionNote: 'Not actual. Just an example.',
      amount: 1.00,
    );
  }

  Widget displayUpiApps(){
    if(apps == null){
      return const Center(child: CircularProgressIndicator(),);
    }else if (apps!.isEmpty){
      return Center(
        child: Text(
            "No apps found to handle transaction.",style: header
        ),
      );
    }else {
      return Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Wrap(
              children: apps!.map<Widget>((UpiApp app) {
                return GestureDetector(
                  onTap: (){
                    _transaction = initiateTransaction(app);
                    setState(() {
                    });
                  },
                  child: Container(
                    height: 100,
                    width: 100,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.memory(
                          app.icon,
                          height: 60,
                          width: 60,
                        ),
                        Text(app.name)
                      ],
                    ),
                  ),
                );
              }).toList()
          ),
        ),
      );
    }
  }

  // String _upiErrorHandler(error){
  //
  // }

  void _checkTxnStatus(String status){
    switch (status){
      case UpiPaymentStatus.SUCCESS:
        print("Transaction Successful");
        break;
      case UpiPaymentStatus.SUBMITTED:
        print("Transaction Submitted");
        break;
      case UpiPaymentStatus.FAILURE:
        print("Transaction Failure");
        break;
      default:
        print("received an unknown transaction status");
    }
  }

  Widget displayTransactionData(title, body){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title", style: header,),
          Flexible(
              child: Text(body,style: value,)
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("UPI Integration"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Expanded(
                child: displayUpiApps()
            ),
            Expanded(
                child: FutureBuilder(
                    future: _transaction,
                    builder: (BuildContext context, AsyncSnapshot<UpiResponse> snapshot){
                      if(snapshot.hasError){
                        return const Center(
                          child: Text(
                              "error found"
                            // _upiErrorHandler(snapshot.error.runtimeType),
                          ),
                        );
                      }
                      UpiResponse _upiresponse = snapshot.data!;
                      String txnId = _upiresponse.transactionId ?? "N/A";
                      String resCode = _upiresponse.responseCode ?? "N/A";
                      String txnRef = _upiresponse.transactionRefId ?? "N/A";
                      String status = _upiresponse.status ?? "N/A";
                      String approvalRef = _upiresponse.approvalRefNo ?? "N/A";
                      _checkTxnStatus(status);
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child:Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            displayTransactionData("Transaction Id", txnId),
                            displayTransactionData("Response Code", resCode),
                            displayTransactionData("Reference Id", txnRef),
                            displayTransactionData("Status", status.toUpperCase()),
                            displayTransactionData("Approval No", approvalRef),
                          ],
                        ),
                      );
                    }
                )
            ),
          ],
        ),
      ),
    );
  }
}
