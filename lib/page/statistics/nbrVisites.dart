import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sales Statistics App',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: SalesStatPage(),
    );
  }
}

class SalesStatPage extends StatefulWidget {
  @override
  _SalesStatPageState createState() => _SalesStatPageState();
}

class _SalesStatPageState extends State<SalesStatPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedGouvernorat = 'Tunis';
  String? _selectedCommercial = 'Commercial 1';

  final Map<String, List<ChartData>> salesData = {
    'Commercial 1': [
      ChartData(DateTime(2024, 12, 1), 30),
      ChartData(DateTime(2024, 12, 2), 50),
      ChartData(DateTime(2024, 12, 3), 70),
    ],
    'Commercial 2': [
      ChartData(DateTime(2024, 12, 1), 20),
      ChartData(DateTime(2024, 12, 2), 40),
      ChartData(DateTime(2024, 12, 3), 60),
    ],
  };

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
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
      return data.where((chartData) {
        final startDate = _startDate!;
        final endDate = _endDate!;
        return chartData.date.isAfter(startDate.subtract(Duration(days: 1))) &&
            chartData.date.isBefore(endDate.add(Duration(days: 1)));
      }).toList();
    }
    return data;
  }

  double _calculateTotalSales() {
    double totalSales = 0.0;
    salesData.forEach((key, value) {
      totalSales += value.fold(0.0, (sum, data) => sum + data.sales);
    });
    return totalSales;
  }

  @override
  Widget build(BuildContext context) {
    double totalSales = _calculateTotalSales();
    Map<String, double> commercialSalesPercentage = {};

    salesData.forEach((commercial, dataList) {
      double commercialTotalSales =
      dataList.fold(0.0, (sum, data) => sum + data.sales);
      commercialSalesPercentage[commercial] =
          (commercialTotalSales / totalSales) * 100;
    });

    List<ChartData> filteredSalesData =
    _filterSalesData(salesData[_selectedCommercial!] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text('Nombre des Visites'),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Horizontal Row with ScrollView for overflow fix
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text('Évolution Prix'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text('Taux Présence'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SalesStatPage()),
                      );
                    },
                    style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text('Nombre Visites'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text('Évolution Ventes'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Evolutionprix()),
                      );
                    },
                    style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text('Disponibilité Produit'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Filters and Charts
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filtrer par',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: buildDateField('Date Début', _startDate, true)),
                      SizedBox(width: 10),
                      Expanded(
                          child: buildDateField('Date Fin', _endDate, false)),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: buildDropdownFilter(
                            'Gouvernorat', ['Tunis', 'Ariana', 'Sfax']),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: buildDropdownFilter(
                            'Commercial', ['Commercial 1', 'Commercial 2']),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Évolution des Visites',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  SfCartesianChart(
                    primaryXAxis: DateTimeAxis(),
                    title: ChartTitle(text: 'Nombre des Visites par Date'),
                    series: <CartesianSeries>[
                      LineSeries<ChartData, DateTime>(
                        dataSource: filteredSalesData,
                        xValueMapper: (ChartData data, _) => data.date,
                        yValueMapper: (ChartData data, _) => data.sales,
                        markerSettings: MarkerSettings(isVisible: true),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Pourcentage des Ventes',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  SfCircularChart(
                    legend: Legend(isVisible: true),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CircularSeries>[
                      PieSeries<MapEntry<String, double>, String>(
                        dataSource: commercialSalesPercentage.entries.toList(),
                        xValueMapper: (MapEntry<String, double> data, _) =>
                        data.key,
                        yValueMapper: (MapEntry<String, double> data, _) =>
                        data.value,
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDateField(String label, DateTime? date, bool isStartDate) {
    return TextField(
      controller: TextEditingController(
        text: date != null ? '${date.toLocal()}'.split(' ')[0] : '',
      ),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today, size: 18),
          onPressed: () {
            _selectDate(context, isStartDate);
          },
        ),
      ),
      readOnly: true,
    );
  }

  Widget buildDropdownFilter(String label, List<String> options) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      value:
      label == 'Commercial' ? _selectedCommercial : _selectedGouvernorat,
      items: options
          .map((e) => DropdownMenuItem<String>(
        child: Text(e),
        value: e,
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          if (label == 'Commercial') {
            _selectedCommercial = value;
          } else {
            _selectedGouvernorat = value;
          }
        });
      },
    );
  }
}

class ChartData {
  final DateTime date;
  final int sales;

  ChartData(this.date, this.sales);
}

class Evolutionprix extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Évolution Prix'),
      ),
      body: Center(
        child: Text('Page for Evolution Prix'),
      ),
    );
  }
}
