import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeeklyForecast extends StatelessWidget {
  final List<Map<String, dynamic>> currentValue;
  final String city;
  final List<dynamic> next7Days;
  const WeeklyForecast({
    super.key,
    required this.city,
    required this.next7Days,
    required this.currentValue,
  });

  String formatApiData(String dataString) {
    final DateFormat inputFormatter = DateFormat('yyyy-MM-dd');
    DateTime date = inputFormatter.parse(dataString);
    final DateFormat outputFormatter = DateFormat('EEEE, dd MMMM ', 'es');

    return outputFormatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      city,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w500,
                        fontFamily: "JetBrains",
                      ),
                    ),
                    Text(
                      "${currentValue[0]['temp_c']}°C",
                      style: TextStyle(
                        fontSize: 33,
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontFamily: "JetBrainsMono",
                      ),
                    ),
                    Image.network(
                      "https:${currentValue[0]['condition']?['icon']}",
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),
              Text(
                "Siguientes ${next7Days.length} dias",
                style: TextStyle(
                  fontFamily: "JetBrainsMono",
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              SizedBox(height: 25),
              ...next7Days.map((day) {
                final data = day['date'] ?? "";
                final icon = day['day']?['condition']?['icon'] ?? "";
                final maxTem = day['day']?['maxtemp_c'] ?? "";
                final minTem = day['day']?['mintemp_c'] ?? "";
                return ListTile(
                  leading: Image.network("https:$icon"),
                  title: Text(
                    formatApiData(data),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontFamily: "JetBrains",
                    ),
                  ),
                  subtitle: Text(
                    "Tem Min: $minTem°C - Tem Max:$maxTem°C",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontFamily: "JetBrains",
                    ),
                  ),
                 
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
