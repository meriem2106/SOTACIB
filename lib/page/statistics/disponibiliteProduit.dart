import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:test_f/page/components/side_menu.dart';

class DisponibiliteProduit extends StatefulWidget {
  @override
  _DisponibiliteProduitPageState createState() => _DisponibiliteProduitPageState();
}

class _DisponibiliteProduitPageState extends State<DisponibiliteProduit> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedProduct = 'Produit 1'; // Default product selection

  // Dummy data for product availability in governorates
  final Map<String, Map<String, double>> productAvailability = {
    'Produit 1': {
      'Tunis': 90,
      'Sousse': 40,
    },
    'Produit 2': {
      'Sousse': 60,
      'Sfax': 20,
    },
  };

  // Method to select start and end dates
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime initialDate = DateTime.now();
    final DateTime firstDate = DateTime(2000);
    final DateTime lastDate = DateTime(2101);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
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

  // Helper function to determine highest and lowest availability governorates
  List<String> _getHighestAndLowestGovernorates(String product) {
    Map<String, double> availability = productAvailability[product] ?? {};
    List<MapEntry<String, double>> sortedEntries = availability.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // Sort descending by value

    String highestGovernorate = sortedEntries.first.key;
    String lowestGovernorate = sortedEntries.last.key;

    return [highestGovernorate, lowestGovernorate];
  }

  @override
  Widget build(BuildContext context) {
    List<String> highestAndLowestGovernorates =
        _getHighestAndLowestGovernorates(_selectedProduct!);

    return Scaffold(
      appBar: AppBar(
        title: Text('Disponibilité Produit'),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      drawer: SideMenu(),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filters Section
            Text(
              'Filtrer par',
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
            SizedBox(height: 10),
            buildDropdownFilter('Produit', ['Produit 1', 'Produit 2']),
            SizedBox(height: 20),

            // Chart Section
            Text(
              'Évolution de la Disponibilité du Produit',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              // Makes sure the chart occupies available space
              child: Container(
                child: SfCartesianChart(
                  primaryXAxis:
                      DateTimeAxis(), // Use DateTimeAxis for the X axis (dates)
                  primaryYAxis: NumericAxis(
                    minimum:
                        0, // Set a minimum value for the Y axis (percentage of availability)
                    maximum:
                        100, // Set a maximum value for the Y axis (percentage of availability)
                    interval:
                        20, // Add interval to make the Y axis more readable
                  ),
                  title: ChartTitle(
                      text: 'Disponibilité du Produit par Gouvernorat'),
                  legend: Legend(isVisible: true),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <CartesianSeries>[
                    // Line series for highest availability governorate
                    LineSeries<ChartData, DateTime>(
                      dataSource: [
                        ChartData(DateTime(2024, 12, 1), 90),
                        ChartData(DateTime(2024, 12, 2), 80),
                        ChartData(DateTime(2024, 12, 3), 85),
                      ],
                      xValueMapper: (ChartData data, _) => data.date,
                      yValueMapper: (ChartData data, _) => data.availability,
                      color: Colors.green,
                      name: 'Gouvernorat avec disponibilité la plus élevée',
                      markerSettings: MarkerSettings(isVisible: true),
                    ),
                    // Line series for lowest availability governorate
                    LineSeries<ChartData, DateTime>(
                      dataSource: [
                        ChartData(DateTime(2024, 12, 1), 30),
                        ChartData(DateTime(2024, 12, 2), 20),
                        ChartData(DateTime(2024, 12, 3), 25),
                      ],
                      xValueMapper: (ChartData data, _) => data.date,
                      yValueMapper: (ChartData data, _) => data.availability,
                      color: Colors.red,
                      name: 'Gouvernorat avec disponibilité la plus basse',
                      markerSettings: MarkerSettings(isVisible: true),
                    ),
                  ],
                ),
              ),
            ),

            // Table of product availability by governorates
            Text(
              'Disponibilité par Gouvernorat',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Table(
              border: TableBorder.all(),
              children: [
                // Header Row
                TableRow(
                  children: [
                    TableCell(
                        child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('Produit'))),
                    ...productAvailability[_selectedProduct!]!.keys.map(
                          (governorate) => TableCell(
                            child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(governorate)),
                          ),
                        ),
                  ],
                ),
                // Data Row (with fixed columns)
                TableRow(
                  children: [
                    TableCell(
                        child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(_selectedProduct!))),
                    ...productAvailability[_selectedProduct!]!.entries.map(
                          (entry) => TableCell(
                            child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Text('${entry.value}%')),
                          ),
                        ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create Date Field
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

  // Helper method to create dropdown filters
  Widget buildDropdownFilter(String label, List<String> options) {
    return SizedBox(
      width: 160,
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        value: _selectedProduct,
        items: options
            .map((e) => DropdownMenuItem<String>(
                  child: Text(e),
                  value: e,
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedProduct = value;
          });
        },
      ),
    );
  }
}

// Data model for chart
class ChartData {
  final DateTime date;
  final double availability;

  ChartData(this.date, this.availability);
}
