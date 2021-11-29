import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:superheroes/blocs/main_bloc.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:superheroes/resources/superheroes_images.dart';

class SuperheroCard extends StatelessWidget {
  final SuperheroInfo superheroInfo;
  final VoidCallback onTap;

  const SuperheroCard({
    Key? key,
    required this.superheroInfo,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: SuperheroesColors.indigo,
        ),
        child: Row(
          children: [
            Container(
              color: Colors.white24,
              width: 70,
              height: 70,
              child: CachedNetworkImage(
                imageUrl: superheroInfo.imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Center(
                  child: Image.asset(
                    SuperheroesImages.unknown,
                    width: 20,
                    height: 62,
                    fit: BoxFit.cover,
                  ),
                ),
                progressIndicatorBuilder: (context, url, progress) => Center(
                  child: Container(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: SuperheroesColors.blue,
                      value: progress.progress,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    superheroInfo.name.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 1.375,
                    ),
                  ),
                  Text(
                    superheroInfo.realName,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 1.375,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
