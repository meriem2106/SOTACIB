import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Évolution des Ventes',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: evolutionVente(),
    );
  }
}

class evolutionVente extends StatefulWidget {
  @override
  _SalesStatPageState createState() => _SalesStatPageState();
}

class _SalesStatPageState extends State<evolutionVente> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedGovernorate = 'Tunis';
  String? _selectedDelegation = 'D1';
  String? _selectedClient = 'Client 1';
  String? _selectedProduct = 'Produit A';
  final String baseUrl = 'http://172.20.10.3:3000/visite/ajouterVisite';

  // Données de vente pour plusieurs produits
  final Map<String, List<ChartData>> salesData = {
    'Produit A': [
      ChartData(DateTime(2024, 12, 1), 30),
      ChartData(DateTime(2024, 12, 2), 50),
      ChartData(DateTime(2024, 12, 3), 70),
    ],
    'Produit B': [
      ChartData(DateTime(2024, 12, 1), 20),
      ChartData(DateTime(2024, 12, 2), 40),
      ChartData(DateTime(2024, 12, 3), 60),
    ],
    'Produit C': [
      ChartData(DateTime(2024, 12, 1), 15),
      ChartData(DateTime(2024, 12, 2), 35),
      ChartData(DateTime(2024, 12, 3), 55),
    ],
    'Produit D': [
      ChartData(DateTime(2024, 12, 1), 25),
      ChartData(DateTime(2024, 12, 2), 45),
      ChartData(DateTime(2024, 12, 3), 65),
    ],
    'Produit E': [
      ChartData(DateTime(2024, 12, 1), 10),
      ChartData(DateTime(2024, 12, 2), 30),
      ChartData(DateTime(2024, 12, 3), 50),
    ],
  };

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('fr', 'FR'),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

 List<ChartData> _filterSalesData(List<ChartData> data) {
  if (_startDate != null && _endDate != null) {
    return data
        .where((chartData) =>
            chartData.date.isAfter(_startDate!.subtract(Duration(days: 1))) &&
            chartData.date.isBefore(_endDate!.add(Duration(days: 1))))
        .toList();  // Convert the Iterable to List
  }
  return data;  // If no date range is selected, return all data
}

  @override
  Widget build(BuildContext context) {
    // Filter the sales data based on the selected product
    List<ChartData> filteredSalesData =
        _filterSalesData(salesData[_selectedProduct!] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text('Évolution des Ventes'),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtrer par Date',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  buildDateField('Date Début', _startDate, true),
                  SizedBox(width: 10),
                  buildDateField('Date Fin', _endDate, false),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Filtrer par Localisation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  buildDropdownFilter(
                      'Gouvernorat', ['Tunis', 'Sfax', 'Ariana']),
                  SizedBox(width: 10),
                  buildDropdownFilter('Délégation', ['D1', 'D2', 'D3']),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Filtrer par Client',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              buildDropdownFilter('Client', ['Client 1', 'Client 2']),
              SizedBox(height: 20),
              Text(
                'Filtrer par Produit',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              buildDropdownFilter('Produit', [
                'Produit A',
                'Produit B',
                'Produit C',
                'Produit D',
                'Produit E',
              ]),
              SizedBox(height: 20),
              Text(
                'Évolution des Ventes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 300,
                child: SfCartesianChart(
                  primaryXAxis: DateTimeAxis(
                    // Customization for the X-axis
                    dateFormat: DateFormat('d MMM'), // Format "1 Dec", "2 Dec", etc.
                    intervalType: DateTimeIntervalType.days,
                    interval: 1, // Interval of 1 day
                  ),
                  primaryYAxis: NumericAxis(
                    title: AxisTitle(text: ''),
                  ),
                  title: ChartTitle(text: 'Ventes par Date'),
                  legend: Legend(isVisible: true),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <CartesianSeries<ChartData, DateTime>>[
                    // Use CartesianSeries explicitly
                    BarSeries<ChartData, DateTime>(
                      dataSource: _filterSalesData(salesData['Produit A'] ?? []),
                      xValueMapper: (ChartData data, _) => data.date,
                      yValueMapper: (ChartData data, _) => data.sales,
                      color: Colors.red,
                      name: 'Produit A',
                      dataLabelSettings: DataLabelSettings(isVisible: true),
                    ),
                    BarSeries<ChartData, DateTime>(
                      dataSource: _filterSalesData(salesData['Produit B'] ?? []),
                      xValueMapper: (ChartData data, _) => data.date,
                      yValueMapper: (ChartData data, _) => data.sales,
                      color: Colors.blue,
                      name: 'Produit B',
                      dataLabelSettings: DataLabelSettings(isVisible: true),
                    ),
                    BarSeries<ChartData, DateTime>(
                      dataSource: _filterSalesData(salesData['Produit C'] ?? []),
                      xValueMapper: (ChartData data, _) => data.date,
                      yValueMapper: (ChartData data, _) => data.sales,
                      color: Colors.green,
                      name: 'Produit C',
                      dataLabelSettings: DataLabelSettings(isVisible: true),
                    ),
                    BarSeries<ChartData, DateTime>(
                      dataSource: _filterSalesData(salesData['Produit D'] ?? []),
                      xValueMapper: (ChartData data, _) => data.date,
                      yValueMapper: (ChartData data, _) => data.sales,
                      color: Colors.orange,
                      name: 'Produit D',
                      dataLabelSettings: DataLabelSettings(isVisible: true),
                    ),
                    BarSeries<ChartData, DateTime>(
                      dataSource: _filterSalesData(salesData['Produit E'] ?? []),
                      xValueMapper: (ChartData data, _) => data.date,
                      yValueMapper: (ChartData data, _) => data.sales,
                      color: Colors.purple,
                      name: 'Produit E',
                      dataLabelSettings: DataLabelSettings(isVisible: true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDateField(String label, DateTime? date, bool isStartDate) {
    return SizedBox(
      width: 158,
      child: TextField(
        controller: TextEditingController(
          text: date != null ? '${date.toLocal()}'.split(' ')[0] : '',
        ),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          suffixIcon: IconButton(
            icon: Icon(Icons.calendar_today,size: 18,),
            onPressed: () {
              _selectDate(context, isStartDate);
            },
          ),
        ),
        readOnly: true,
      ),
    );
  }

  Widget buildDropdownFilter(String label, List<String> options) {
    return SizedBox(
      width: 130,
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        value: label == 'Produit'
            ? _selectedProduct
            : label == 'Client'
                ? _selectedClient
                : label == 'Gouvernorat'
                    ? _selectedGovernorate
                    : _selectedDelegation,
        items: options
            .map((e) => DropdownMenuItem<String>(
                  child: Text(e),
                  value: e,
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            if (label == 'Produit') {
              _selectedProduct = value;
            } else if (label == 'Client') {
              _selectedClient = value;
            } else if (label == 'Gouvernorat') {
              _selectedGovernorate = value;
            } else if (label == 'Délégation') {
              _selectedDelegation = value;
            }
          });
        },
      ),
    );
  }
}

class ChartData {
  final DateTime date;
  final int sales;

  ChartData(this.date, this.sales);
}
