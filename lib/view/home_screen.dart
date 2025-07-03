import 'package:app_clima/provider/theme_provider.dart';
import 'package:app_clima/services/api_services.dart';
import 'package:app_clima/view/weekly_forecast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final weatherServices = WeatherApiServices();
  String city = "Hermosillo";
  String country = "";
  List<Map<String, dynamic>> currentValue = [];
  List<dynamic> hourly = [];
  List<dynamic> pastWeek = [];
  List<dynamic> next7Days = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> newCurrentValue;
    List<dynamic> newHourly;
    List<dynamic> newNext7Days;
    List<dynamic> newPastWeek;
    String newCity;
    String newCountry;
    bool success = false;

    try {
      final results = await Future.wait([
        weatherServices.getHourlyForecast(city),
        weatherServices.getDaySevenForecast(city),
      ]);

      final forecast = results[0] as Map<String, dynamic>;
      final past = results[1] as List<dynamic>;

      newCurrentValue = forecast['current'];
      newHourly = forecast['forecast']?['forecastday']?[0]?['hour'] ?? [];
      newNext7Days = forecast['forecast']?['forecastday'] ?? [];
      newPastWeek = past;
      newCity = forecast["location"]["name"];
      newCountry = forecast["location"]["country"];
      success = true;
    } catch (e) {
      newCurrentValue = {};
      newHourly = [];
      newNext7Days = [];
      newPastWeek = [];
      newCity = city; // Mantenemos el nombre de la ciudad anterior
      newCountry = country; // Mantenemos el país anterior
      success = false;
    }

    if (mounted) {
      setState(() {
        currentValue = [newCurrentValue];
        hourly = newHourly;
        next7Days = newNext7Days;
        pastWeek = newPastWeek;
        city = newCity;
        country = newCountry;
        isLoading = false;
      });

      // 6. Muestra un SnackBar si hubo un error.
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "La ciudad es invalida. Porfavor de verificar",
              style: TextStyle(
                fontFamily: "JetBrains",
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
        );
      }
    }
  }

  String formatTime(String timeString) {
    final DateTime? time = DateTime.tryParse(timeString);

    if (time == null) {
      return '--';
    }
    return DateFormat.j().format(time);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNofierProvider);
    final notifier = ref.read(themeNofierProvider.notifier);
    final isDark = themeMode == ThemeMode.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: TextField(
                style: TextStyle(
                  fontFamily: "JetBrains",
                  color: Theme.of(context).colorScheme.surface,
                ),
                onSubmitted: (value) {
                  if (value.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "La ciudad es invalida.",
                          style: TextStyle(
                            fontFamily: "JetBrainsMono",
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                      ),
                    );
                  }
                  city = value.trim();
                  getData();
                },
                decoration: InputDecoration(
                  hintStyle: TextStyle(
                    fontFamily: "JetBrains",
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  labelText: "Buscar ciudad",
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  labelStyle: TextStyle(
                    fontFamily: "JetBrainsMono",
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: notifier.toggleTheme,
            child: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: Theme.of(context).colorScheme.surface,
              size: 30,
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            Column(
              children: [
                const Center(child: CircularProgressIndicator()),
                SizedBox(height: 8),
                Text(
                  "Cargando...",
                  style: TextStyle(
                    fontFamily: "JetBrainsMono",
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ],
            )
          else ...[
            if (currentValue.isNotEmpty)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$city${country.isNotEmpty ? ", $country" : ""}",
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

                  SizedBox(height: 15),
                  Image.network("https:${currentValue[0]['condition']?['icon']}", height: 200,
                  fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Container(
                      height: 110,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.secondary,
                            offset: Offset(1, 1),
                            blurRadius: 9,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Icon(
                                     Icons.local_fire_department,
                                      size: 30,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                    ),
                                    Text(
                                      "${currentValue[0]['uv']}",
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                        fontFamily: "JetBrainsMono",
                                      ),
                                    ),
                                    Text(
                                      "UV",
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                        fontFamily: "JetBrainsMono",
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Icon(
                                      Icons.water_drop_sharp,
                                      size: 30,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                    ),
                                    Text(
                                      "${next7Days[0]['day']?['daily_chance_of_rain'] ?? ""}%",
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                        fontFamily: "JetBrainsMono",
                                      ),
                                    ),
                                    Text(
                                      "Prob. Lluvia",
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                        fontFamily: "JetBrainsMono",
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.sunny,
                                      size: 30,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                    ),
                                    Text(
                                      "${next7Days[0]['day']?['maxtemp_c'] ?? ""}°C",
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                        fontFamily: "JetBrainsMono",
                                      ),
                                    ),
                                    Text(
                                      "Temp Max",
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                        fontFamily: "JetBrainsMono",
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    width: double.maxFinite,
                    height: 240,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Today ",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.surface,
                                  fontFamily: "JetBrainsMono",
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    (context),
                                    MaterialPageRoute(
                                      builder: (context) => WeeklyForecast(
                                        city: city,
                                  
                                        next7Days: next7Days, currentValue: currentValue,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Weekly",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    fontFamily: "JetBrainsMono",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: Theme.of(context).colorScheme.secondary),
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: hourly.length,
                            itemBuilder: (context, index) {
                              final hour = hourly[index];
                              final now = DateTime.now();
                              final hourTime = DateTime.parse(hour['time']);
                              final isCurrentHour =
                                  now.hour == hourTime.hour &&
                                  now.day == hourTime.day;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isCurrentHour
                                        ? Colors.yellow
                                        : Colors.black38,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        isCurrentHour
                                            ? "Ahora"
                                            : formatTime(hour['time']),
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                          fontFamily: "JetBrainsMono",
                                          fontSize: 16,
                                        ),
                                      ),

                                      const SizedBox(height: 10),
                                      Image.network(
                                        "https:${hour['condition']?['icon']}",
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "${hour['temp_c'].toString().substring(0, hour['temp_c'].toString().length - 2)}°C",
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                          fontFamily: "JetBrainsMono",
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}
