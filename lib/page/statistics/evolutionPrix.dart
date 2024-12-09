import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../components/side_menu.dart';
import 'disponibiliteProduit.dart';
import 'evolutionVentes.dart';
import 'nbrVisites.dart'; // Import DisponibiliteProduit

class Evolutionprix extends StatefulWidget {
  @override
  _PrixStatPageState createState() => _PrixStatPageState();
}

class _PrixStatPageState extends State<Evolutionprix> {
  List<ChartData> chartDataConcurrent = [];
  List<ChartData> chartDataCommercial = [];
  bool isLoading = false;

  List<String> gouvernorats = ['Tunis', 'Sfax', 'Sousse'];
  List<String> concurrents = [
    'Sotacib Kairouan',
    'Carthage Ciment',
    'Ciment Jbel Oust',
    'Les ciments de Bizerte'
  ];
  List<String> produits = [
    'CEM I 42,5',
    'CEM II 32,5',
    'CEM I 42,5 SR-3',
    'CHAUX'
  ];

  String? selectedGouvernorat;
  String? selectedConcurent;
  String? selectedProduit;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    chartDataConcurrent = [];
    chartDataCommercial = [];
  }

  void fetchPrixEvolution() {
    if (selectedGouvernorat == null ||
        selectedConcurent == null ||
        selectedProduit == null ||
        _startDate == null ||
        _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Veuillez sélectionner tous les filtres."),
      ));
      return;
    }

    setState(() {
      isLoading = true;
    });

    List<ChartData> data1 = [
      ChartData("Jan", 10),
      ChartData("Feb", 20),
      ChartData("Mar", 30),
    ];
    List<ChartData> data2 = [
      ChartData("Jan", 15),
      ChartData("Feb", 25),
      ChartData("Mar", 35),
    ];

    switch (selectedGouvernorat) {
      case 'Tunis':
        chartDataConcurrent = data1;
        chartDataCommercial = data2;
        break;
      case 'Sfax':
        chartDataConcurrent = data2;
        chartDataCommercial = data1;
        break;
      default:
        chartDataConcurrent = [];
        chartDataCommercial = [];
    }

    setState(() {
      isLoading = false;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Évolution Prix'),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      drawer: SideMenu(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Horizontal navigation buttons
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Evolutionprix()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: Text('Évolution Prix'),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DisponibiliteProduit()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: Text('Disponibilité Produit'),
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

                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: Text('Nombre Visites'),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => evolutionVente()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: Text('Evolution Ventes'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Filters
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      buildDropdownFilter('Gouvernorat', gouvernorats, (value) {
                        setState(() {
                          selectedGouvernorat = value;
                        });
                      }),
                      buildDropdownFilter('Concurrent', concurrents, (value) {
                        setState(() {
                          selectedConcurent = value;
                        });
                      }),
                      buildDropdownFilter('Produit', produits, (value) {
                        setState(() {
                          selectedProduit = value;
                        });
                      }),
                      buildDateField('Date Début', _startDate, true),
                      buildDateField('Date Fin', _endDate, false),
                      ElevatedButton(
                        onPressed: fetchPrixEvolution,
                        child: Text('Filtrer'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Chart Section
                  Expanded(
                    child: chartDataConcurrent.isEmpty &&
                            chartDataCommercial.isEmpty
                        ? Center(child: Text('Aucune donnée disponible.'))
                        : SfCartesianChart(
                            primaryXAxis: CategoryAxis(),
                            title: ChartTitle(text: 'Prix en Dinars (TND)'),
                            legend: Legend(isVisible: true),
                            tooltipBehavior: TooltipBehavior(enable: true),
                            series: <LineSeries<ChartData, String>>[
                              LineSeries<ChartData, String>(
                                dataSource: chartDataConcurrent,
                                xValueMapper: (ChartData data, _) => data.x,
                                yValueMapper: (ChartData data, _) => data.y,
                                name: 'Prix Concurrent',
                                color: Colors.red,
                              ),
                              LineSeries<ChartData, String>(
                                dataSource: chartDataCommercial,
                                xValueMapper: (ChartData data, _) => data.x,
                                yValueMapper: (ChartData data, _) => data.y,
                                name: 'Prix Commercial',
                                color: Colors.blue,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildDropdownFilter(
      String label, List<String> options, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: options
          .map((option) => DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget buildDateField(String label, DateTime? date, bool isStartDate) {
    return SizedBox(
      width: 160,
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
}

class ChartData {
  final String x;
  final double y;

  ChartData(this.x, this.y);
}
