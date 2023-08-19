import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/dummy_stocks.dart';
import 'package:frontend/models/stock_model.dart';
import 'package:frontend/providers/stock_filters_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/models/user_model.dart';

class AddStockDialog extends StatelessWidget {
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
  Widget build(BuildContext context) {
    String? deltaInput;
    String? maxHoldingsInput;
    String? maxPriceInput;
    String? strategyInput;

    return AlertDialog(
      title: const Text('Add Stock'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: ListBody(
            children: <Widget>[
              TextFormField(
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
                decoration: const InputDecoration(
                  labelText: 'Delta (0-1)',
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  maxHoldingsInput = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Max Collateral',
                ),
                validator: (value) {
                  double? val = double.tryParse(value ?? '');
                  if (val == null || val < 0) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  maxPriceInput = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Max Price',
                ),
                validator: (value) {
                  double? val = double.tryParse(value ?? '');
                  if (val == null || val < 0) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: strategyInput,
                hint: const Text('Select Strategy'),
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
              addStockToUserList(
                stock.ticker,
                stock.company,
                deltaInput!,
                maxHoldingsInput!,
                maxPriceInput!,
                strategyInput!,
              );

              final snackBar = SnackBar(
                content:
                    Text('You have added ${stock.company} to your watchlist'),
                backgroundColor: Colors.green.shade400,
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
          child: Text('Cancel'),
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
