import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/stock_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/widgets/header_tooltip.dart';

class AddStockDialog extends ConsumerWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Stock stock;
  final UserModel userData;
  final Function addStockToUserList;
  final Function removeStockFromUserList;
  final Function stockExistsInUserList;

  AddStockDialog(
      {super.key,
      required this.stock,
      required this.addStockToUserList,
      required this.userData,
      required this.stockExistsInUserList,
      required this.removeStockFromUserList});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? maxHoldingsInput;
    String? maxPriceInput;
    String? strategyInput;

    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      backgroundColor: const Color.fromARGB(255, 22, 22, 23),
      elevation: 0,
      title: SizedBox(
        height: 45,
        width: double.infinity,
        child: Text(
          stock.company,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 26),
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // const HeaderWithTooltip(
              //   header: 'Delta (0-1)',
              //   tooltipText:
              //       'Delta represents the probability that an option will end up in the money. For a cash-secured put, it essentially indicates the likelihood of being assigned the stock.',
              // ),
              // SizedBox(
              //   height: 35,
              //   child: TextFormField(
              //     style: const TextStyle(
              //         color: Color.fromARGB(206, 255, 255, 255)),
              //     keyboardType: TextInputType.number,
              //     onChanged: (value) {
              //       double? val = double.tryParse(value);
              //       if (val != null) {
              //         deltaInput = val.toStringAsFixed(2);
              //       } else {
              //         deltaInput = value;
              //       }
              //     },
              //     validator: (value) {
              //       double? val = double.tryParse(value ?? '');
              //       if (val == null || val < 0 || val > 1) {
              //         return 'Enter a valid number between 0 and 1';
              //       }
              //       return null;
              //     },
              //   ),
              // ),
              // const SizedBox(height: 20),
              const HeaderWithTooltip(
                header: 'Max Collateral',
                tooltipText:
                    'Max collateral is the maximum amount reserved as security for a cash-secured put. If exercised, it represents the maximum sum you\'d spend to purchase the stock.',
              ),
              SizedBox(
                height: 35,
                child: TextFormField(
                  style: const TextStyle(
                      color: Color.fromARGB(206, 255, 255, 255)),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    double? val = double.tryParse(value);
                    if (val != null) {
                      maxHoldingsInput = val.toStringAsFixed(2);
                    } else {
                      maxHoldingsInput =
                          value; // Keeping the original string if it's not valid
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
                header: 'Max Price',
                tooltipText:
                    'Max Price is the highest price you are willing to pay for this stock.',
              ),
              SizedBox(
                height: 35,
                child: TextFormField(
                  style: const TextStyle(
                      color: Color.fromARGB(206, 255, 255, 255)),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    double? val = double.tryParse(value);
                    if (val != null) {
                      maxPriceInput = val.toStringAsFixed(2);
                    } else {
                      maxPriceInput =
                          value; // Keeping the original string if it's not valid
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
                header: 'Strategy',
                tooltipText:
                    'Conservative strategies are less risky, but also less profitable and give fewer recs (far from the money). Aggressive strategies are more risky (closer to the money), but also more profitable and give you more recs. Balanced strategies are somewhere in between.',
              ),
              SizedBox(
                height: 40,
                child: DropdownButtonFormField<String>(
                  dropdownColor: Color.fromARGB(255, 53, 52, 52),
                  style: const TextStyle(
                      color: Color.fromARGB(206, 255, 255, 255), fontSize: 16),
                  borderRadius: BorderRadius.circular(10),
                  elevation: 0,
                  value: strategyInput,
                  hint: const Text('Select Strategy',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  items: <String>['Aggressive', 'Balanced', 'Conservative']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    strategyInput = value;
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Select a strategy';
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
              addStockToUserList(stock.ticker, stock.company, maxHoldingsInput!,
                  maxPriceInput!, strategyInput!, ref);

              final snackBar = SnackBar(
                content:
                    Text('You have added ${stock.company} to your watchlist'),
                backgroundColor: Colors.purple,
                duration: const Duration(seconds: 2),
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
