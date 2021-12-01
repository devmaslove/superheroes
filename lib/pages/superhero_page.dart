import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:superheroes/model/biography.dart';
import 'package:superheroes/model/powerstats.dart';
import 'package:superheroes/model/server_image.dart';
import 'package:superheroes/model/superhero.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:superheroes/widgets/action_button.dart';

class SuperheroPage extends StatelessWidget {
  final String id;

  const SuperheroPage({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final superhero = Superhero(
      name: "Batman",
      biography: Biography(
        fullName: "Vasya Pupkin",
        alignment: "good",
        aliases: ["Batan", "Botik"],
        placeOfBirth: "Russia, Vologda",
      ),
      image: ServerImage(
        url: "https://www.superherodb.com/pictures2/portraits/10/100/639.jpg",
      ),
      powerstats: Powerstats(
        intelligence: "90",
        strength: "80",
        speed: "16",
        durability: "45",
        power: "100",
        combat: "0",
      ),
      id: id,
    );
    return Scaffold(
      backgroundColor: SuperheroesColors.background,
      body: CustomScrollView(
        slivers: [
          SuperheroAppBar(superhero: superhero),
          SliverToBoxAdapter(),
        ],
      ),
    );
  }
}

class SuperheroAppBar extends StatelessWidget {
  const SuperheroAppBar({
    Key? key,
    required this.superhero,
  }) : super(key: key);

  final Superhero superhero;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      stretch: true,
      pinned: true,
      floating: true,
      expandedHeight: 348,
      backgroundColor: SuperheroesColors.background,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          superhero.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        background: CachedNetworkImage(
          imageUrl: superhero.image.url,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
