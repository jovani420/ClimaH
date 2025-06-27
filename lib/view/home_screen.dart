import 'package:app_clima/provider/theme_provider.dart';
import 'package:app_clima/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final weatherServices = WeatherApiServices();
  String city = "Hermosillo";
  String coutry = "";
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
    // 1. Inicia el estado de carga y reconstruye el widget para mostrar el indicador.
    setState(() {
      isLoading = true;
    });

    // Variables locales para almacenar los nuevos datos o el estado de error.
    Map<String, dynamic> newCurrentValue;
    List<dynamic> newHourly;
    List<dynamic> newNext7Days;
    List<dynamic> newPastWeek;
    String newCity;
    String newCountry;
    bool success = false;

    try {
      // 2. Realiza las llamadas a la API en paralelo para ser más eficiente.
      final results = await Future.wait([
        weatherServices.getHourlyForecast(city),
        weatherServices.getDaySevenForecast(city),
      ]);

      final forecast = results[0] as Map<String, dynamic>;
      final past = results[1] as List<dynamic>;

      // 3. Asigna los datos a las variables locales si la llamada fue exitosa.
      newCurrentValue = forecast['current'];
      newHourly = forecast['forecast']?['forecastday']?[0]?['hour'] ?? [];
      newNext7Days = forecast['forecast']?['forecastday'] ?? [];
      newPastWeek = past;
      newCity = forecast["location"]["name"];
      newCountry = forecast["location"]["country"];
      success = true;
    } catch (e) {
      // 4. En caso de error, asigna valores por defecto.
      newCurrentValue = {};
      newHourly = [];
      newNext7Days = [];
      newPastWeek = [];
      newCity = city; // Mantenemos el nombre de la ciudad anterior
      newCountry = coutry; // Mantenemos el país anterior
      success = false;
    }

    // 5. Si el widget todavía está montado, actualiza el estado una sola vez.
    if (mounted) {
      setState(() {
        currentValue = [newCurrentValue];
        hourly = newHourly;
        next7Days = newNext7Days;
        pastWeek = newPastWeek;
        city = newCity;
        coutry = newCountry;
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
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$city${coutry.isNotEmpty ? ", $coutry" : ""}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 31,
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w500,
                        fontFamily: "JetBrains",
                      ),
                    ),
                    Text(
                      "${currentValue[0]['temp_c']}°C",
                      style: TextStyle(
                        fontSize: 50,
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontFamily: "JetBrainsMono",
                      ),
                    ),
                    Text(
                      "${currentValue[0]['condition']['text']}",
                      style: TextStyle(
                        fontSize: 30,
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontFamily: "JetBrains",
                      ),
                    ),
                    SizedBox(height: 15),
                    Image.asset("assets/weather/Sunny.png", height: 200),
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: Container(
                        height: 100,
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          // Puedes cambiar el color aquí. Por ejemplo, a un azul claro.
                          color: Theme.of(context).colorScheme.onSecondary,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.surface,
                              offset: Offset(1, 3.5),
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
                                        Icons.water_drop_sharp,
                                        size: 30,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                      ),
                                      Text(
                                        "${currentValue[0]['humidity']}%",
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                          fontFamily: "JetBrainsMono",
                                        ),
                                      ),
                                      Text(
                                        "Humedad",
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
                                        Icons.wind_power,
                                        size: 30,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                      ),
                                      Text(
                                        "${currentValue[0]['wind_kph']}k/h",
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                          fontFamily: "JetBrainsMono",
                                        ),
                                      ),
                                      Text(
                                        "Viento",
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
                                        "${currentValue[0]['humidity']}°C",
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
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
