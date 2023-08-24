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
    String? deltaInput;
    String? maxHoldingsInput;
    String? maxPriceInput;
    String? strategyInput;

    return AlertDialog(
      title: SizedBox(
        height: 45,
        width: double.infinity,
        child: Text(
          stock.company,
          textAlign: TextAlign.center,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const HeaderWithTooltip(
                header: 'Delta (0-1)',
                tooltipText:
                    'Delta represents the probability that an option will end up in the money. For a cash-secured put, it essentially indicates the likelihood of not incurring a loss.',
              ),
              SizedBox(
                height: 35,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    deltaInput = value;
                  },
                  validator: (value) {
                    double? val = double.tryParse(value ?? '');
                    if (val == null || val < 0 || val > 1) {
                      return 'Enter a valid number between 0 and 1';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              const HeaderWithTooltip(
                header: 'Max Collateral',
                tooltipText:
                    'Max collateral is the maximum amount reserved as security for a cash-secured put. If exercised, it represents the maximum sum you\'d spend to purchase the stock.',
              ),
              SizedBox(
                height: 35,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    maxHoldingsInput = value;
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
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    maxPriceInput = value;
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
                    'Conservative strategies are less risky, but also less profitable. Aggressive strategies are more risky, but also more profitable. Balanced strategies are somewhere in between.',
              ),
              SizedBox(
                height: 40,
                child: DropdownButtonFormField<String>(
                  value: strategyInput,
                  hint: const Text('Select Strategy',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  items: <String>['Balanced', 'Aggressive', 'Conservative']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
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
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              Navigator.of(context).pop();
              addStockToUserList(stock.ticker, stock.company, deltaInput!,
                  maxHoldingsInput!, maxPriceInput!, strategyInput!, ref);

              final snackBar = SnackBar(
                content:
                    Text('You have added ${stock.company} to your watchlist'),
                backgroundColor: Colors.purple,
                duration: const Duration(seconds: 2),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          },
          child: const Text('Add'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

// Future<void> _showAddStockDialog(BuildContext context, Stock stock,
//     UserModel userData, Function addStockToUserList) async {
//   String? deltaInput;
//   String? maxHoldingsInput;
//   String? maxPriceInput;
//   String? strategyInput;

//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//         return AlertDialog(
//           title: const Text('Add Stock'),
//           content: SingleChildScrollView(
//             child: Form(
//               key: _formKey,
//               child: ListBody(
//                 children: <Widget>[
//                   TextFormField(
//                     keyboardType: TextInputType.number,
//                     onChanged: (value) {
//                       deltaInput = value;
//                     },
//                     validator: (value) {
//                       double? val = double.tryParse(value ?? '');
//                       if (val == null || val < 0 || val > 1) {
//                         return 'Enter a valid number between 0 and 1';
//                       }
//                       return null;
//                     },
//                     decoration: const InputDecoration(
//                       labelText: 'Delta (0-1)',
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   TextFormField(
//                     keyboardType: TextInputType.number,
//                     onChanged: (value) {
//                       maxHoldingsInput = value;
//                     },
//                     decoration: const InputDecoration(
//                       labelText: 'Max Collateral',
//                     ),
//                     validator: (value) {
//                       double? val = double.tryParse(value ?? '');
//                       if (val == null || val < 0) {
//                         return 'Enter a valid number';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   TextFormField(
//                     keyboardType: TextInputType.number,
//                     onChanged: (value) {
//                       maxPriceInput = value;
//                     },
//                     decoration: const InputDecoration(
//                       labelText: 'Max Price',
//                     ),
//                     validator: (value) {
//                       double? val = double.tryParse(value ?? '');
//                       if (val == null || val < 0) {
//                         return 'Enter a valid number';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   DropdownButtonFormField<String>(
//                     value: strategyInput,
//                     hint: const Text('Select Strategy'),
//                     items: <String>['Balanced', 'Aggressive', 'Conservative']
//                         .map((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       strategyInput = value;
//                     },
//                     validator: (value) {
//                       if (value == null) {
//                         return 'Select a strategy';
//                       }
//                       return null;
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 if (_formKey.currentState!.validate()) {
//                   _formKey.currentState!.save();
//                   Navigator.of(context).pop();
//                   addStockToUserList(
//                     stock.ticker,
//                     stock.company,
//                     deltaInput!,
//                     maxHoldingsInput!,
//                     maxPriceInput!,
//                     strategyInput!,
//                   );

//                   final snackBar = SnackBar(
//                     content: Text(
//                         'You have added ${stock.company} to your watchlist'),
//                     backgroundColor: Colors.green.shade400,
//                     duration: const Duration(seconds: 2),
//                   );
//                   ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                 }
//               },
//               child: const Text('Add'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel'),
//             ),
//           ],
//         );
//       });
// }
