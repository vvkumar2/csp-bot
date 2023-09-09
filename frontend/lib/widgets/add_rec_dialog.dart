import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/recommendation_model.dart';
import 'package:frontend/models/stock_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/util.dart';
import 'package:frontend/widgets/header_tooltip.dart';

class AddRecDialog extends ConsumerWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Recommendation recommendation;
  final Function addRecToUserList;
  final Function setRecToSold;

  AddRecDialog(
      {super.key,
      required this.recommendation,
      required this.addRecToUserList,
      required this.setRecToSold});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String bidInput = recommendation.bidPrice.toStringAsFixed(2);
    String quantityInput = recommendation.optionQuantity.toString();

    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      backgroundColor: const Color.fromARGB(255, 22, 22, 23),
      elevation: 0,
      title: const SizedBox(
        height: 45,
        width: double.infinity,
        child: Text(
          "Did you sell this option?",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 26),
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const HeaderWithTooltip(
                header: 'Your Bid Price',
                tooltipText: 'The bid price that you sold the option for.',
              ),
              SizedBox(
                height: 35,
                child: TextFormField(
                  style: const TextStyle(
                      color: Color.fromARGB(206, 255, 255, 255)),
                  keyboardType: TextInputType.number,
                  initialValue: bidInput,
                  onChanged: (value) {
                    double? val = double.tryParse(value);
                    if (val != null) {
                      bidInput = val.toStringAsFixed(2);
                    } else {
                      bidInput = value;
                    }
                  },
                  validator: (value) {
                    double? val = double.tryParse(value ?? '');
                    if (val == null || val < 0) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              const HeaderWithTooltip(
                header: 'Quantity Sold',
                tooltipText:
                    'The number of options you sold. Ex. If you sold 2 contracts, enter 2.',
              ),
              SizedBox(
                height: 35,
                child: TextFormField(
                  style: const TextStyle(
                      color: Color.fromARGB(206, 255, 255, 255)),
                  keyboardType: TextInputType.number,
                  initialValue: quantityInput,
                  onChanged: (value) {
                    int? val = int.tryParse(value);
                    if (val != null) {
                      quantityInput = val.toString();
                    } else {
                      quantityInput = value;
                    }
                  },
                  validator: (value) {
                    int? val = int.tryParse(value ?? '');
                    if (val == null || val < 0) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.purple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              Navigator.of(context).pop();
              addRecToUserList(
                Recommendation(
                    ticker: recommendation.ticker,
                    expiryDate: recommendation.expiryDate,
                    strikePrice: recommendation.strikePrice,
                    bidPrice: double.parse(bidInput!),
                    optionQuantity: int.parse(quantityInput!),
                    delta: recommendation.delta,
                    isSold: true),
                ref,
              );
              setRecToSold(recommendation, ref);

              const snackBar = SnackBar(
                content: Text(
                    'Looks good! We will notify you when you should sell this!'),
                backgroundColor: Colors.purple,
                duration: Duration(seconds: 2),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          },
          child: const Text('Add', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.purple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
