import 'package:flutter/material.dart';
import 'package:compile_project/domain/entities/pokemon_detail_entity.dart';
import 'package:compile_project/utils/utils.dart';

class PokemonWidget extends StatelessWidget {
  final PokemonDetailEntity pokemonDetail;
  final Function onTap;
  const PokemonWidget({
    Key? key,
    required this.pokemonDetail,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: (MediaQuery.of(context).size.width - 40) / 3,
          height: 186,
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Utils.capitalize(pokemonDetail.name.toString()),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                width: (MediaQuery.of(context).size.width - 40) / 3,
                color: Colors.green[50],
                child: Image.network(
                  pokemonDetail.imageUrl,
                  height: 104,
                  width: 104,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.white,
                width: (MediaQuery.of(context).size.width - 40) / 3,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(pokemonDetail.speciesTypes[0]),
                        Spacer(),
                        Text(
                          pokemonDetail.weight.toString(),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
