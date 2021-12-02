import 'dart:async';
import 'dart:convert';

import 'package:flutter/animation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:superheroes/exception/api_exception.dart';
import 'package:superheroes/favorite_superheroes_storage.dart';
import 'package:superheroes/model/superhero.dart';

class SuperheroBloc {
  http.Client? client;
  final String id;

  final superheroSubject = BehaviorSubject<Superhero>();

  StreamSubscription? requestSubscription;
  StreamSubscription? addToFavoriteSubscription;
  StreamSubscription? getFromFavoriteSubscription;
  StreamSubscription? removeFromFavoriteSubscription;

  SuperheroBloc({
    this.client,
    required this.id,
  }) {
    getFromFavorites();
  }

  Stream<Superhero> observeSuperhero() => superheroSubject;

  void getFromFavorites() {
    getFromFavoriteSubscription?.cancel();
    getFromFavoriteSubscription = FavoriteSuperheroesStorage.getInstance()
        .getSuperhero(id)
        .asStream()
        .listen(
      (superhero) {
        if (superhero != null) {
          superheroSubject.add(superhero);
        }
        requestSuperhero();
      },
      onError: (error, stackTrace) {
        print("Error happened in getFromFavorites: $error, $stackTrace");
      },
    );
  }

  void addToFavorite() {
    final superhero = superheroSubject.valueOrNull;
    if (superhero != null) {
      addToFavoriteSubscription?.cancel();
      addToFavoriteSubscription = FavoriteSuperheroesStorage.getInstance()
          .addToFavorites(superhero)
          .asStream()
          .listen(
        (event) {
          print('Added to favorites: $event');
        },
        onError: (error, stackTrace) {
          print("Error happened in addToFavorite: $error, $stackTrace");
        },
      );
    }
  }

  void removeFromFavorites() {
    removeFromFavoriteSubscription?.cancel();
    removeFromFavoriteSubscription = FavoriteSuperheroesStorage.getInstance()
        .removeFromFavorites(id)
        .asStream()
        .listen(
      (event) {
        print('Removed from favorites: $event');
      },
      onError: (error, stackTrace) {
        print("Error happened in removeFromFavorites: $error, $stackTrace");
      },
    );
  }

  Stream<bool> observeIsFavorite() =>
      FavoriteSuperheroesStorage.getInstance().observeIsFavorite(id);

  void requestSuperhero() {
    requestSubscription?.cancel();
    requestSubscription = request().asStream().listen(
      (superhero) {
        superheroSubject.add(superhero);
      },
      onError: (error, stackTrace) {
        print("Error happened in requestSuperhero: $error, $stackTrace");
      },
    );
  }

  Future<Superhero> request() async {
    final token = dotenv.env["SUPERHERO_TOKEN"];
    final response = await (client ??= http.Client()).get(
      Uri.parse("https://superheroapi.com/api/$token/$id"),
    );
    if (response.statusCode >= 500 && response.statusCode <= 599) {
      throw ApiException('Server error happened');
    } else if (response.statusCode >= 400 && response.statusCode <= 499) {
      throw ApiException('Client error happened');
    } else if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      print(decoded);
      if (decoded['response'] == 'success') {
        return Superhero.fromJson(decoded);
      } else if (decoded['response'] == 'error') {
        throw ApiException('Client error happened');
      }
    }
    throw Exception('Unknown error happened');
  }

  void dispose() {
    client?.close();
    requestSubscription?.cancel();
    getFromFavoriteSubscription?.cancel();
    addToFavoriteSubscription?.cancel();
    removeFromFavoriteSubscription?.cancel();
    superheroSubject.close();
  }
}
