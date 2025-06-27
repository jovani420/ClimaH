import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const apiKey = "9d3730d96d344cc187e190815252206";

class WeatherApiServices {

  Future<Map<String, dynamic>> getHourlyForecast(String location) async {
    final url = Uri.parse(
      "http://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$location&days=7",
    );

    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception("A ocurred a error");
    }
    final data = jsonDecode(res.body);
    return data;
  }

  Future<List<Map<String, dynamic>>> getDaySevenForecast(
    String location,
  ) async {
    final List<Map<String, dynamic>> pastWeather = [];
    final today = DateTime.now();

    for (int i = 0; i <= 7; i++) {
      final data = today.subtract(Duration(days: i));

      final formattedDate =
          "${data.year}-${data.month.toString().padLeft(2, "0")}-${data.day.toString().padLeft(2, "0")}";

      final url = Uri.parse(
        "http://api.weatherapi.com/v1/history.json?key=$apiKey&q=$location&dt=$formattedDate",
      );
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (data['forecast']?['forecastday'] != null) {
          pastWeather.add(data);
        } else {
          debugPrint("No hay datos para esta fecha $formattedDate $res.body");
        }
      }
    }
    return pastWeather;
  }
}
