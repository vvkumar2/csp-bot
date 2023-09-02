import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/watchlist_stock_model.dart';
import 'package:frontend/widgets/header_tooltip.dart';

class EditStockDialog extends ConsumerWidget {
  EditStockDialog(
      {super.key, required this.stock, required this.addStockToUserList});
  final WatchlistStock stock;
  final Function addStockToUserList;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? deltaInput = stock.delta.toString();
    String? maxHoldingsInput = stock.maxHoldings.toString();
    String? maxPriceInput = stock.maxPrice.toString();
    String? strategyInput = stock.strategy;

    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 32, 32, 33),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      elevation: 0,
      title: SizedBox(
        height: 45,
        width: double.infinity,
        child: Text(
          stock.company,
          style: const TextStyle(
            fontSize: 28,
            color: Colors.white,
          ),
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
                  style: const TextStyle(
                      color: Color.fromARGB(206, 255, 255, 255)),
                  initialValue: stock.delta.toString(),
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
                  style: const TextStyle(
                      color: Color.fromARGB(206, 255, 255, 255)),
                  initialValue: stock.maxHoldings.toString(),
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
                  style: const TextStyle(
                      color: Color.fromARGB(206, 255, 255, 255)),
                  initialValue: stock.maxPrice.toString(),
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
                  hint: const Text('Select a strategy',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  items: <String>['Balanced', 'Aggressive', 'Conservative']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value,
                          style: const TextStyle(
                              color: Color.fromARGB(206, 255, 255, 255))),
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
              addStockToUserList(stock.ticker, stock.company, deltaInput!,
                  maxHoldingsInput!, maxPriceInput!, strategyInput!, ref);

              final snackBar = SnackBar(
                content: Text('You have successfully edited ${stock.company}'),
                backgroundColor: Colors.purple,
                duration: const Duration(seconds: 2),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          },
          child: const Text('Confirm', style: TextStyle(color: Colors.white)),
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
