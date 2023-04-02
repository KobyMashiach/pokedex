import 'package:flutter/material.dart';
import 'package:compile_project/constants/image_constants.dart';
import 'package:compile_project/domain/entities/pokemon_detail_entity.dart';
import 'package:compile_project/utils/utils.dart';

class PokemonDetailDisplay extends StatelessWidget {
  final PokemonDetailEntity pokemonDetailEntity;
  const PokemonDetailDisplay({
    Key? key,
    required this.pokemonDetailEntity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          pokemonDetailEntity.name,
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Image.network(pokemonDetailEntity.imageUrl),
        detailsText(
            title: "National No", detail: pokemonDetailEntity.id.toString()),
        detailsText(
          title: "Type",
          detail: pokemonDetailEntity.speciesTypes[0].toUpperCase(),
          color: getTypeColor(pokemonDetailEntity.speciesTypes[0]),
        ),
        detailsText(
            title: "Height",
            detail:
                "${pokemonDetailEntity.height / 10} m (${(pokemonDetailEntity.height / 10 * 3.28).round()}'00'')"),
        detailsText(
            title: "Weight",
            detail:
                "${pokemonDetailEntity.weight / 10} kg (${(pokemonDetailEntity.weight / 10 * 2.204).toStringAsFixed(1)} ibs)"),
      ],
    );
  }

  Color getTypeColor(String type) {
    switch (type) {
      case "fire":
        return Colors.red;
      case "grass":
        return Colors.green;
      case "Water":
        return const Color.fromARGB(255, 144, 202, 249);
      default:
        return Colors.white;
    }
  }
}

class detailsText extends StatelessWidget {
  final String title;
  final String detail;
  final Color? color;

  const detailsText(
      {super.key, required this.title, required this.detail, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40, bottom: 5),
      child: Column(
        children: [
          const Divider(color: Color.fromARGB(255, 184, 184, 184)),
          Row(
            children: [
              Text(title),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 120),
                child: Container(
                  width: 110,
                  height: 40,
                  color: color ?? Colors.white,
                  child: Center(
                    child: Text(
                      detail,
                      style:
                          TextStyle(color: color != null ? Colors.white : null),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
