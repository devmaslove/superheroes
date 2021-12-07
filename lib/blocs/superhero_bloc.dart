import 'dart:async';
import 'dart:convert';

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
  final superheroPageState = BehaviorSubject<SuperheroPageState>();

  StreamSubscription? requestSubscription;
  StreamSubscription? updateFavoriteSubscription;
  StreamSubscription? addToFavoriteSubscription;
  StreamSubscription? getFromFavoriteSubscription;
  StreamSubscription? removeFromFavoriteSubscription;

  SuperheroBloc({
    this.client,
    required this.id,
  }) {
    getFromFavorites();
  }

  Stream<Superhero> observeSuperhero() => superheroSubject.distinct();

  Stream<SuperheroPageState> observeSuperheroPageState() =>
      superheroPageState.distinct();

  void getFromFavorites() {
    getFromFavoriteSubscription?.cancel();
    getFromFavoriteSubscription = FavoriteSuperheroesStorage.getInstance()
        .getSuperhero(id)
        .asStream()
        .listen(
      (superhero) {
        if (superhero != null) {
          superheroSubject.add(superhero);
          superheroPageState.add(SuperheroPageState.loaded);
        } else {
          superheroPageState.add(SuperheroPageState.loading);
        }
        requestSuperhero(superhero != null);
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

  void updateFavorite() {
    final superhero = superheroSubject.valueOrNull;
    if (superhero != null) {
      print("Do update favorite: $superhero");
      updateFavoriteSubscription?.cancel();
      updateFavoriteSubscription = FavoriteSuperheroesStorage.getInstance()
          .updateFavorites(superhero)
          .asStream()
          .listen(
        (event) {
          if (event) print('Updated favorites: $event');
        },
        onError: (error, stackTrace) {
          print("Error happened in updateFavorite: $error, $stackTrace");
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

  void requestSuperhero(final bool isInFavorite) {
    requestSubscription?.cancel();
    requestSubscription = request().asStream().listen(
      (superhero) {
        superheroSubject.add(superhero);
        // мы зазгрузили из файворитов и получили обновление
        // нужно обновить избранного
        if (isInFavorite) updateFavorite();
        superheroPageState.add(SuperheroPageState.loaded);
      },
      onError: (error, stackTrace) {
        if (!isInFavorite) superheroPageState.add(SuperheroPageState.error);
        print("Error happened in requestSuperhero: $error, $stackTrace");
      },
    );
  }

  void retry() {
    superheroPageState.add(SuperheroPageState.loading);
    requestSuperhero(false);
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
      print("Request server by id: $decoded");
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
    updateFavoriteSubscription?.cancel();
    removeFromFavoriteSubscription?.cancel();
    superheroSubject.close();
    superheroPageState.close();
  }
}

enum SuperheroPageState {
  loading,
  loaded,
  error,
}
